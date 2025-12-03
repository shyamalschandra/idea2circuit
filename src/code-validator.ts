import { exec } from 'child_process';
import { promisify } from 'util';
import { writeFileSync, unlinkSync, readFileSync } from 'fs';
import { join } from 'path';
import { GeneratedCode, ValidationIssue } from './types';

const execAsync = promisify(exec);

export interface ValidationReport {
  success: boolean;
  errors: ValidationIssue[];
  warnings: ValidationIssue[];
  summary: string;
  categorizedIssues: {
    syntax: ValidationIssue[];
    semantic: ValidationIssue[];
    typeErrors: ValidationIssue[];
    undeclared: ValidationIssue[];
    unused: ValidationIssue[];
    other: ValidationIssue[];
  };
}

export class CodeValidator {
  private tempDir: string;

  constructor(tempDir: string = '/tmp/flux-circuits') {
    this.tempDir = tempDir;
  }

  /**
   * Validate C code by compiling it and checking for warnings/errors
   */
  async validateCode(code: string, maxRetries: number = 5): Promise<GeneratedCode> {
    console.log('   🔍 Running pre-validation checks...');
    
    // Pre-validation: Check for basic syntax issues
    const preCheck = this.preValidateCode(code);
    if (!preCheck.passed) {
      console.log(`   ⚠️  Pre-validation found ${preCheck.issues.length} potential issues`);
      for (const issue of preCheck.issues.slice(0, 3)) {
        console.log(`      - ${issue}`);
      }
    }

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
        console.log('   ✅ Validation passed: Code is error-free and warning-free');
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
          const errorReport = this.formatDetailedErrors(result.errors);
          throw new Error(`Failed to fix code after ${maxRetries} attempts.\n\n${errorReport}`);
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

  /**
   * Pre-validate code before compilation
   */
  private preValidateCode(code: string): { passed: boolean; issues: string[] } {
    const issues: string[] = [];

    // Check for balanced braces
    const openBraces = (code.match(/{/g) || []).length;
    const closeBraces = (code.match(/}/g) || []).length;
    if (openBraces !== closeBraces) {
      issues.push(`Unbalanced braces: ${openBraces} opening, ${closeBraces} closing`);
    }

    // Check for balanced parentheses (basic check)
    const openParens = (code.match(/\(/g) || []).length;
    const closeParens = (code.match(/\)/g) || []).length;
    if (openParens !== closeParens) {
      issues.push(`Unbalanced parentheses: ${openParens} opening, ${closeParens} closing`);
    }

    // Check for common C syntax requirements
    if (!code.includes('#include')) {
      issues.push('No #include directives found - may be missing header files');
    }

    // Check for main function if it looks like a complete program
    if (code.includes('int main') && !code.match(/int\s+main\s*\(/)) {
      issues.push('Malformed main function declaration');
    }

    // Check for unclosed strings (basic check)
    const lines = code.split('\n');
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const inComment = line.trim().startsWith('//') || line.trim().startsWith('/*');
      if (!inComment) {
        const quotes = (line.match(/"/g) || []).length;
        if (quotes % 2 !== 0) {
          issues.push(`Line ${i + 1}: Unclosed string literal`);
        }
      }
    }

    return {
      passed: issues.length === 0,
      issues
    };
  }

  /**
   * Format errors with detailed categorization
   */
  private formatDetailedErrors(errors: string[]): string {
    const categorized = this.categorizeErrors(errors);
    let report = '📋 COMPILATION ERRORS:\n';
    report += '═'.repeat(60) + '\n\n';

    if (categorized.syntax.length > 0) {
      report += '❌ SYNTAX ERRORS:\n';
      categorized.syntax.forEach((err, i) => {
        report += `   ${i + 1}. ${err}\n`;
      });
      report += '\n';
    }

    if (categorized.typeErrors.length > 0) {
      report += '❌ TYPE ERRORS:\n';
      categorized.typeErrors.forEach((err, i) => {
        report += `   ${i + 1}. ${err}\n`;
      });
      report += '\n';
    }

    if (categorized.undeclared.length > 0) {
      report += '❌ UNDECLARED IDENTIFIERS:\n';
      categorized.undeclared.forEach((err, i) => {
        report += `   ${i + 1}. ${err}\n`;
      });
      report += '\n';
    }

    if (categorized.semantic.length > 0) {
      report += '❌ SEMANTIC ERRORS:\n';
      categorized.semantic.forEach((err, i) => {
        report += `   ${i + 1}. ${err}\n`;
      });
      report += '\n';
    }

    if (categorized.other.length > 0) {
      report += '❌ OTHER ERRORS:\n';
      categorized.other.forEach((err, i) => {
        report += `   ${i + 1}. ${err}\n`;
      });
      report += '\n';
    }

    report += `Total: ${errors.length} error(s)\n`;
    return report;
  }

  /**
   * Categorize errors by type
   */
  private categorizeErrors(errors: string[]): {
    syntax: string[];
    semantic: string[];
    typeErrors: string[];
    undeclared: string[];
    unused: string[];
    other: string[];
  } {
    const result = {
      syntax: [] as string[],
      semantic: [] as string[],
      typeErrors: [] as string[],
      undeclared: [] as string[],
      unused: [] as string[],
      other: [] as string[]
    };

    for (const error of errors) {
      const lower = error.toLowerCase();
      
      if (lower.includes('syntax') || lower.includes('expected') || 
          lower.includes('parse') || lower.includes('before')) {
        result.syntax.push(error);
      } else if (lower.includes('undeclared') || lower.includes('not declared') ||
                 lower.includes('undefined reference')) {
        result.undeclared.push(error);
      } else if (lower.includes('type') || lower.includes('incompatible') ||
                 lower.includes('conflicting types')) {
        result.typeErrors.push(error);
      } else if (lower.includes('unused') || lower.includes('never used')) {
        result.unused.push(error);
      } else if (lower.includes('semantic') || lower.includes('invalid')) {
        result.semantic.push(error);
      } else {
        result.other.push(error);
      }
    }

    return result;
  }

  /**
   * Generate a comprehensive validation report
   */
  async generateValidationReport(code: string): Promise<ValidationReport> {
    const result = await this.compileAndCheck(code);
    
    const errors: ValidationIssue[] = result.errors.map(e => this.parseCompilerMessage(e, 'error'));
    const warnings: ValidationIssue[] = result.warnings.map(w => this.parseCompilerMessage(w, 'warning'));
    
    const categorized = {
      syntax: [...errors.filter(e => e.category === 'syntax'), ...warnings.filter(w => w.category === 'syntax')],
      semantic: [...errors.filter(e => e.category === 'semantic'), ...warnings.filter(w => w.category === 'semantic')],
      typeErrors: [...errors.filter(e => e.category === 'type'), ...warnings.filter(w => w.category === 'type')],
      undeclared: [...errors.filter(e => e.category === 'undeclared'), ...warnings.filter(w => w.category === 'undeclared')],
      unused: [...errors.filter(e => e.category === 'unused'), ...warnings.filter(w => w.category === 'unused')],
      other: [...errors.filter(e => e.category === 'other'), ...warnings.filter(w => w.category === 'other')]
    };

    const summary = this.generateSummary(errors, warnings, categorized);

    return {
      success: errors.length === 0,
      errors,
      warnings,
      summary,
      categorizedIssues: categorized
    };
  }

  /**
   * Parse compiler message into structured format
   */
  private parseCompilerMessage(message: string, severity: 'error' | 'warning'): ValidationIssue {
    // Example format: temp.c:10:5: error: 'x' undeclared
    const lineMatch = message.match(/:(\d+):(\d+):/);
    const line = lineMatch ? parseInt(lineMatch[1]) : undefined;
    const column = lineMatch ? parseInt(lineMatch[2]) : undefined;
    
    // Determine category
    const lower = message.toLowerCase();
    let category: ValidationIssue['category'] = 'other';
    
    if (lower.includes('syntax') || lower.includes('expected') || lower.includes('parse')) {
      category = 'syntax';
    } else if (lower.includes('undeclared') || lower.includes('undefined reference')) {
      category = 'undeclared';
    } else if (lower.includes('type') || lower.includes('incompatible')) {
      category = 'type';
    } else if (lower.includes('unused')) {
      category = 'unused';
    } else if (lower.includes('semantic') || lower.includes('invalid')) {
      category = 'semantic';
    }

    // Extract suggestion if available
    let suggestion: string | undefined;
    if (lower.includes('did you mean')) {
      const suggestionMatch = message.match(/did you mean ['"](.+?)['"]/i);
      if (suggestionMatch) {
        suggestion = `Consider using '${suggestionMatch[1]}'`;
      }
    }

    return {
      message: message.replace(/^.*?:\d+:\d+:\s*(error|warning):\s*/, '').trim(),
      severity,
      line,
      column,
      category,
      suggestion,
      fullMessage: message
    };
  }

  /**
   * Generate summary of validation issues
   */
  private generateSummary(errors: ValidationIssue[], warnings: ValidationIssue[], categorized: any): string {
    if (errors.length === 0 && warnings.length === 0) {
      return '✅ Code validation passed with no issues';
    }

    let summary = '';
    
    if (errors.length > 0) {
      summary += `❌ ${errors.length} error(s) found:\n`;
      const categories = Object.entries(categorized)
        .filter(([_, issues]: [string, any]) => issues.some((i: ValidationIssue) => i.severity === 'error'))
        .map(([cat, issues]: [string, any]) => {
          const errorCount = issues.filter((i: ValidationIssue) => i.severity === 'error').length;
          return `  - ${errorCount} ${cat} error(s)`;
        });
      summary += categories.join('\n') + '\n';
    }

    if (warnings.length > 0) {
      summary += `⚠️  ${warnings.length} warning(s) found:\n`;
      const categories = Object.entries(categorized)
        .filter(([_, issues]: [string, any]) => issues.some((i: ValidationIssue) => i.severity === 'warning'))
        .map(([cat, issues]: [string, any]) => {
          const warnCount = issues.filter((i: ValidationIssue) => i.severity === 'warning').length;
          return `  - ${warnCount} ${cat} warning(s)`;
        });
      summary += categories.join('\n');
    }

    return summary;
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

      // Log detailed results
      if (errors.length > 0) {
        console.log(`   ❌ Found ${errors.length} compilation error(s)`);
      }
      if (warnings.length > 0) {
        console.log(`   ⚠️  Found ${warnings.length} compilation warning(s)`);
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
      console.log(`   ❌ Compilation failed: ${errorMessage.split('\n')[0]}`);
      
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
