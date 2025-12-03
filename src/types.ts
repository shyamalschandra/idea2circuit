export type HardwareTarget = 'ASIC' | 'FPGA' | 'TPU' | 'QPU' | 'OPU' | 'LPU' | 'GPU';

export interface CodeGenerationRequest {
  idea: string;
  characteristics: string[];
  maxRetries?: number;
}

export interface GeneratedCode {
  code: string;
  warnings: string[];
  errors: string[];
  lineCount: number;
}

export interface TestResult {
  type: 'UX' | 'regression' | 'unit' | 'blackbox' | 'A-B';
  passed: boolean;
  message: string;
}

export interface CircuitGenerationRequest {
  cCode: string;
  target: HardwareTarget;
  optimizationLevel: number;
}

export interface CircuitResult {
  schematic: string;
  optimized: boolean;
  target: HardwareTarget;
  metadata: Record<string, any>;
}
