import { exec } from 'child_process';
import { promisify } from 'util';
import { writeFileSync, unlinkSync, readFileSync } from 'fs';
import { join } from 'path';
import { GeneratedCode } from './types';

const execAsync = promisify(exec);

export class CodeValidator {
  private tempDir: string;

  constructor(tempDir: string = '/tmp/flux-circuits') {
    this.tempDir = tempDir;
  }

  /**
   * Validate C code by compiling it and checking for warnings/errors
   */
  async validateCode(code: string, maxRetries: number = 5): Promise<GeneratedCode> {
    let currentCode = code;
    let attempt = 0;
    let allWarnings: string[] = [];
    let allErrors: string[] = [];

    while (attempt < maxRetries) {
      const result = await this.compileAndCheck(currentCode);
      
      allWarnings = result.warnings;
      allErrors = result.errors;

      if (result.errors.length === 0 && result.warnings.length === 0) {
        // Code is clean
        return {
          code: currentCode,
          warnings: [],
          errors: [],
          lineCount: currentCode.split('\n').length
        };
      }

      if (result.errors.length > 0) {
        // Has errors, need to fix
        attempt++;
        if (attempt >= maxRetries) {
          throw new Error(`Failed to fix code after ${maxRetries} attempts. Errors: ${result.errors.join('; ')}`);
        }
        // Return current state - caller should improve code
        return {
          code: currentCode,
          warnings: result.warnings,
          errors: result.errors,
          lineCount: currentCode.split('\n').length
        };
      }

      // Only warnings, might be acceptable
      if (result.warnings.length > 0 && attempt < maxRetries - 1) {
        attempt++;
        // Continue to try fixing warnings
        return {
          code: currentCode,
          warnings: result.warnings,
          errors: [],
          lineCount: currentCode.split('\n').length
        };
      }

      break;
    }

    return {
      code: currentCode,
      warnings: allWarnings,
      errors: allErrors,
      lineCount: currentCode.split('\n').length
    };
  }

  private async compileAndCheck(code: string): Promise<{ warnings: string[]; errors: string[] }> {
    const tempFile = join(this.tempDir, `temp_${Date.now()}.c`);
    const outputFile = join(this.tempDir, `temp_${Date.now()}.o`);

    try {
      // Ensure temp directory exists
      await execAsync(`mkdir -p ${this.tempDir}`);

      // Write code to temp file
      writeFileSync(tempFile, code, 'utf-8');

      // Compile with strict warnings
      const compileCommand = `gcc -Wall -Wextra -Werror -pedantic -std=c11 -c ${tempFile} -o ${outputFile} 2>&1 || gcc -Wall -Wextra -pedantic -std=c11 -c ${tempFile} -o ${outputFile} 2>&1`;
      
      const { stderr, stdout } = await execAsync(compileCommand);
      const output = stderr || stdout;

      const warnings: string[] = [];
      const errors: string[] = [];

      if (output) {
        const lines = output.split('\n');
        for (const line of lines) {
          if (line.includes('error:')) {
            errors.push(line.trim());
          } else if (line.includes('warning:')) {
            warnings.push(line.trim());
          }
        }
      }

      // Cleanup
      try {
        unlinkSync(tempFile);
        if (readFileSync(outputFile)) {
          unlinkSync(outputFile);
        }
      } catch (e) {
        // Ignore cleanup errors
      }

      return { warnings, errors };
    } catch (error: any) {
      // Cleanup on error
      try {
        unlinkSync(tempFile);
      } catch (e) {
        // Ignore
      }

      const errorMessage = error.stderr || error.message || 'Unknown compilation error';
      return {
        warnings: [],
        errors: [errorMessage]
      };
    }
  }

  /**
   * Add copyright notice to code
   */
  addCopyright(code: string): string {
    const copyright = `/*\n * Copyright (C) 2025, Shyamal Suhana Chandra\n */\n\n`;
    
    // Check if copyright already exists
    if (code.includes('Copyright (C) 2025')) {
      return code;
    }

    // Add after any existing comments at the top
    const lines = code.split('\n');
    let insertIndex = 0;

    // Skip existing comments
    while (insertIndex < lines.length && 
           (lines[insertIndex].trim().startsWith('/*') || 
            lines[insertIndex].trim().startsWith('//') ||
            lines[insertIndex].trim() === '')) {
      insertIndex++;
    }

    lines.splice(insertIndex, 0, ...copyright.trim().split('\n'));
    return lines.join('\n');
  }
}
