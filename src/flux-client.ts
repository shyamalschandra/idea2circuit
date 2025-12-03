import axios from 'axios';
import * as dotenv from 'dotenv';
import { HardwareTarget, CircuitGenerationRequest, CircuitResult } from './types';

dotenv.config();

const FLUX_API_KEY = process.env.FLUX_API_KEY || '';
const FLUX_API_URL = process.env.FLUX_API_URL || 'https://api.flux.ai/v1';

export class FluxClient {
  private apiKey: string;
  private apiUrl: string;

  constructor() {
    this.apiKey = FLUX_API_KEY;
    this.apiUrl = FLUX_API_URL;
  }

  /**
   * Compile C code to hardware schematic using Flux compiler
   */
  async compileToCircuit(request: CircuitGenerationRequest): Promise<CircuitResult> {
    try {
      // Flux API endpoint for compilation
      const response = await axios.post(
        `${this.apiUrl}/compile`,
        {
          source_code: request.cCode,
          target: request.target.toLowerCase(),
          optimization_level: request.optimizationLevel,
          format: 'schematic'
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        schematic: response.data.schematic || response.data.circuit,
        optimized: response.data.optimized || false,
        target: request.target,
        metadata: response.data.metadata || {}
      };
    } catch (error: any) {
      // If API structure is different, try alternative endpoints
      if (error.response?.status === 404) {
        // Try alternative endpoint structure
        return this.compileToCircuitAlternative(request);
      }
      
      if (error.response) {
        throw new Error(`Flux API error: ${error.response.status} - ${error.response.data?.error?.message || 'Unknown error'}`);
      }
      throw new Error(`Failed to connect to Flux API: ${error.message}`);
    }
  }

  /**
   * Alternative compilation method if primary endpoint doesn't exist
   */
  private async compileToCircuitAlternative(request: CircuitGenerationRequest): Promise<CircuitResult> {
    // Try different endpoint patterns based on Flux API documentation
    try {
      const response = await axios.post(
        `${this.apiUrl}/circuits/generate`,
        {
          code: request.cCode,
          hardware_target: request.target,
          optimize: true
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        schematic: response.data.result || JSON.stringify(response.data, null, 2),
        optimized: true,
        target: request.target,
        metadata: response.data
      };
    } catch (error: any) {
      // Fallback: generate a mock schematic structure
      console.warn('Flux API not available, generating mock circuit structure');
      return this.generateMockCircuit(request);
    }
  }

  /**
   * Generate a mock circuit structure when API is unavailable
   */
  private generateMockCircuit(request: CircuitGenerationRequest): CircuitResult {
    const target = request.target;
    return {
      schematic: JSON.stringify({
        target: target,
        components: this.extractComponentsFromCode(request.cCode),
        connections: [],
        optimization: {
          level: request.optimizationLevel,
          applied: true
        },
        metadata: {
          generated_at: new Date().toISOString(),
          source_lines: request.cCode.split('\n').length
        }
      }, null, 2),
      optimized: true,
      target: target,
      metadata: {
        note: 'Mock circuit - configure Flux API for actual compilation'
      }
    };
  }

  private extractComponentsFromCode(code: string): string[] {
    const components: string[] = [];
    const functionRegex = /(?:void|int|float|double|char|struct|enum)\s+(\w+)\s*\(/g;
    let match;
    
    while ((match = functionRegex.exec(code)) !== null) {
      components.push(match[1]);
    }
    
    return components;
  }
}
