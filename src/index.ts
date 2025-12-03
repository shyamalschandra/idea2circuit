#!/usr/bin/env node

import { CursorClient } from './cursor-client.js';
import { FluxClient } from './flux-client.js';
import { CodeValidator } from './code-validator.js';
import { TestGenerator } from './test-generator.js';
import { HardwareTarget, CodeGenerationRequest, CircuitGenerationRequest } from './types';
import { writeFileSync, mkdirSync } from 'fs';
import { join } from 'path';

export class IdeaToCircuitConverter {
  private cursorClient: CursorClient;
  private fluxClient: FluxClient;
  private codeValidator: CodeValidator;
  private testGenerator: TestGenerator;

  // Buzzword characteristics
  private readonly characteristics = [
    'modular',
    'fault-tolerant',
    'security',
    'atomicity',
    'concurrent',
    'parallel',
    'distributed',
    'cache coherent',
    'encrypted',
    'protocol-driven',
    'robust',
    'asynchronous',
    'producer-consumer',
    'synchronized',
    'optimized',
    'lightweight'
  ];

  constructor() {
    this.cursorClient = new CursorClient();
    this.fluxClient = new FluxClient();
    this.codeValidator = new CodeValidator();
    this.testGenerator = new TestGenerator();
  }

  /**
   * Generate detailed issue descriptions for better error fixing
   */
  private async generateDetailedIssues(code: string, errors: string[], warnings: string[]): Promise<string> {
    const lines = code.split('\n');
    let details = 'Issues found:\n';
    
    // Extract line numbers from errors and show context
    for (const error of errors.slice(0, 5)) {
      const lineMatch = error.match(/:(\d+):/);
      if (lineMatch) {
        const lineNum = parseInt(lineMatch[1]);
        details += `\nError at line ${lineNum}:\n`;
        details += `  ${error}\n`;
        
        // Show code context
        if (lineNum > 0 && lineNum <= lines.length) {
          const start = Math.max(0, lineNum - 2);
          const end = Math.min(lines.length, lineNum + 1);
          details += '  Code context:\n';
          for (let i = start; i < end; i++) {
            const marker = i === lineNum - 1 ? '→' : ' ';
            details += `  ${marker} ${i + 1}: ${lines[i]}\n`;
          }
        }
      } else {
        details += `\n${error}\n`;
      }
    }
    
    return details;
  }

  /**
   * Main conversion pipeline: Idea -> C Code -> Circuit
   */
  async convert(idea: string, target: HardwareTarget, maxRetries: number = 5): Promise<{
    code: string;
    tests: any[];
    circuit: any;
  }> {
    console.log(`\n🚀 Converting idea to ${target} circuit...`);
    console.log(`💡 Idea: "${idea}"\n`);

    // Step 1: Generate initial C code
    console.log('📝 Step 1: Generating C code from idea...');
    let code = await this.cursorClient.generateCode(idea, this.characteristics);
    console.log(`✅ Generated ${code.split('\n').length} lines of code`);

    // Step 2: Recursively improve code until bug-free and warning-free
    console.log('\n🔧 Step 2: Validating and improving code...');
    console.log('   📊 Initial validation...');
    
    let validationResult = await this.codeValidator.validateCode(code, maxRetries);
    let attempts = 0;
    let previousErrors = validationResult.errors.length;
    let previousWarnings = validationResult.warnings.length;

    // Show initial validation report
    if (validationResult.errors.length > 0 || validationResult.warnings.length > 0) {
      const report = await this.codeValidator.generateValidationReport(code);
      console.log(`\n   📋 Validation Report:`);
      console.log(`   ${report.summary.split('\n').join('\n   ')}`);
      
      // Show top 3 errors if any
      if (report.errors.length > 0) {
        console.log(`\n   🔍 Top issues to fix:`);
        report.errors.slice(0, 3).forEach((err, i) => {
          console.log(`      ${i + 1}. [Line ${err.line || '?'}] ${err.message}`);
          if (err.suggestion) {
            console.log(`         💡 ${err.suggestion}`);
          }
        });
      }
    }

    while ((validationResult.errors.length > 0 || validationResult.warnings.length > 0) && attempts < maxRetries) {
      attempts++;
      console.log(`\n   🔄 Revision attempt ${attempts}/${maxRetries}`);
      console.log(`   📊 Current state: ${validationResult.errors.length} errors, ${validationResult.warnings.length} warnings`);

      if (validationResult.errors.length > 0) {
        console.log(`   🔨 Requesting code improvements for ${validationResult.errors.length} error(s)...`);
        
        // Generate detailed issue description
        const detailedIssues = await this.generateDetailedIssues(code, validationResult.errors, validationResult.warnings);
        
        code = await this.cursorClient.improveCode(code, validationResult.warnings, validationResult.errors);
        console.log(`   ✅ Received improved code (${code.split('\n').length} lines)`);
        
        // Re-validate
        console.log(`   🔍 Validating revised code...`);
        validationResult = await this.codeValidator.validateCode(code, 1);
        
        // Show progress
        if (validationResult.errors.length < previousErrors) {
          console.log(`   ✅ Progress: Fixed ${previousErrors - validationResult.errors.length} error(s)`);
        } else if (validationResult.errors.length > previousErrors) {
          console.log(`   ⚠️  Warning: Errors increased from ${previousErrors} to ${validationResult.errors.length}`);
        }
        
        previousErrors = validationResult.errors.length;
        previousWarnings = validationResult.warnings.length;
        
      } else if (validationResult.warnings.length > 0) {
        console.log(`   🔨 Requesting code improvements for ${validationResult.warnings.length} warning(s)...`);
        code = await this.cursorClient.improveCode(code, validationResult.warnings, []);
        console.log(`   ✅ Received improved code (${code.split('\n').length} lines)`);
        
        // Re-validate
        console.log(`   🔍 Validating revised code...`);
        validationResult = await this.codeValidator.validateCode(code, 1);
        
        // Show progress
        if (validationResult.warnings.length < previousWarnings) {
          console.log(`   ✅ Progress: Fixed ${previousWarnings - validationResult.warnings.length} warning(s)`);
        }
        
        previousWarnings = validationResult.warnings.length;
      }
    }

    if (validationResult.errors.length > 0) {
      const finalReport = await this.codeValidator.generateValidationReport(code);
      console.log(`\n   ❌ Final Validation Report:`);
      console.log(`   ${finalReport.summary.split('\n').join('\n   ')}`);
      throw new Error(`Failed to fix all errors after ${maxRetries} attempts. Please review the validation report above.`);
    }

    console.log(`\n   ✅ Code validated successfully!`);
    if (validationResult.warnings.length > 0) {
      console.log(`   ℹ️  ${validationResult.warnings.length} acceptable warning(s) remain`);
    } else {
      console.log(`   ✅ No errors or warnings`);
    }

    // Step 3: Add copyright notice
    console.log('\n©️  Step 3: Adding copyright notice...');
    code = this.codeValidator.addCopyright(code);
    console.log('✅ Copyright added');

    // Step 4: Generate and run comprehensive tests
    console.log('\n🧪 Step 4: Generating and running tests (20 tests per line)...');
    const tests = await this.testGenerator.generateAndRunTests(code);
    const passedTests = tests.filter(t => t.passed).length;
    const totalTests = tests.length;
    console.log(`✅ Tests completed: ${passedTests}/${totalTests} passed`);

    // Step 5: Check design patterns
    console.log('\n🎨 Step 5: Checking design patterns and software engineering fitness...');
    const designCheck = this.testGenerator.checkDesignPatterns(code);
    if (!designCheck.passed) {
      console.warn(`⚠️  Design pattern issues: ${designCheck.issues.join(', ')}`);
    } else {
      console.log('✅ Design patterns validated');
    }

    // Step 6: Compile to circuit using Flux
    console.log(`\n⚡ Step 6: Compiling to ${target} circuit using Flux compiler...`);
    const circuitRequest: CircuitGenerationRequest = {
      cCode: code,
      target: target,
      optimizationLevel: 3
    };

    const circuit = await this.fluxClient.compileToCircuit(circuitRequest);
    console.log(`✅ Circuit generated for ${target}`);

    return {
      code,
      tests,
      circuit
    };
  }
}

// CLI interface
if (import.meta.url === `file://${process.argv[1]}`) {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.error('Usage: node dist/index.js "<idea>" <target>');
    console.error('Targets: ASIC, FPGA, TPU, QPU, OPU, LPU, GPU');
    process.exit(1);
  }

  const idea = args[0];
  const target = args[1].toUpperCase() as HardwareTarget;

  if (!['ASIC', 'FPGA', 'TPU', 'QPU', 'OPU', 'LPU', 'GPU'].includes(target)) {
    console.error(`Invalid target: ${target}`);
    console.error('Valid targets: ASIC, FPGA, TPU, QPU, OPU, LPU, GPU');
    process.exit(1);
  }

  const converter = new IdeaToCircuitConverter();
  converter.convert(idea, target)
    .then(result => {
      // Create output directory
      const outputDir = join(process.cwd(), 'output');
      try {
        mkdirSync(outputDir, { recursive: true });
      } catch (e) {
        // Directory might already exist
      }

      // Generate timestamp for filenames
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
      const prefix = `circuit_${timestamp}`;

      // Save C code
      const codeFile = join(outputDir, `${prefix}_code.c`);
      writeFileSync(codeFile, result.code, 'utf-8');

      // Save test results
      const testFile = join(outputDir, `${prefix}_tests.json`);
      writeFileSync(testFile, JSON.stringify(result.tests, null, 2), 'utf-8');

      // Save circuit
      const circuitFile = join(outputDir, `${prefix}_circuit.json`);
      writeFileSync(circuitFile, JSON.stringify(result.circuit, null, 2), 'utf-8');

      console.log('\n' + '='.repeat(60));
      console.log('📊 RESULTS');
      console.log('='.repeat(60));
      console.log('\n📄 Generated C Code:');
      console.log('-'.repeat(60));
      console.log(result.code);
      console.log('\n🧪 Test Results Summary:');
      console.log('-'.repeat(60));
      const testSummary = result.tests.reduce((acc, test) => {
        acc[test.type] = acc[test.type] || { passed: 0, total: 0 };
        acc[test.type].total++;
        if (test.passed) acc[test.type].passed++;
        return acc;
      }, {} as Record<string, { passed: number; total: number }>);
      
      for (const [type, stats] of Object.entries(testSummary)) {
        const stat = stats as { passed: number; total: number };
        console.log(`${type}: ${stat.passed}/${stat.total} passed`);
      }
      
      console.log('\n⚡ Circuit Schematic:');
      console.log('-'.repeat(60));
      console.log(result.circuit.schematic);
      console.log('\n💾 Files saved:');
      console.log(`  - C code: ${codeFile}`);
      console.log(`  - Tests: ${testFile}`);
      console.log(`  - Circuit: ${circuitFile}`);
      console.log('\n✅ Conversion complete!\n');
    })
    .catch(error => {
      console.error('\n❌ Error:', error.message);
      if (error.stack) {
        console.error(error.stack);
      }
      process.exit(1);
    });
}
