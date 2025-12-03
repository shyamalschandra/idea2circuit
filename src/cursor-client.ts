import axios from 'axios';
import * as dotenv from 'dotenv';

dotenv.config();

const CURSOR_API_KEY = process.env.CURSOR_API_KEY || '';
const CURSOR_API_URL = process.env.CURSOR_API_URL || 'https://api.cursor.com/v1';

export class CursorClient {
  private apiKey: string;
  private apiUrl: string;

  constructor() {
    this.apiKey = CURSOR_API_KEY;
    this.apiUrl = CURSOR_API_URL;
  }

  /**
   * Generate C code from an idea using Cursor Headless CLI API
   */
  async generateCode(idea: string, characteristics: string[]): Promise<string> {
    const prompt = this.buildPrompt(idea, characteristics);
    
    try {
      const response = await axios.post(
        `${this.apiUrl}/chat/completions`,
        {
          model: 'gpt-4',
          messages: [
            {
              role: 'system',
              content: 'You are an expert C programmer specializing in embedded systems, hardware design, and high-performance computing. Generate production-ready, optimized C code.'
            },
            {
              role: 'user',
              content: prompt
            }
          ],
          temperature: 0.3,
          max_tokens: 4000
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const generatedCode = response.data.choices[0].message.content;
      return this.extractCodeFromResponse(generatedCode);
    } catch (error: any) {
      if (error.response) {
        throw new Error(`Cursor API error: ${error.response.status} - ${error.response.data?.error?.message || 'Unknown error'}`);
      }
      throw new Error(`Failed to connect to Cursor API: ${error.message}`);
    }
  }

  /**
   * Improve code by fixing warnings and errors
   */
  async improveCode(code: string, warnings: string[], errors: string[]): Promise<string> {
    const issues = [...warnings, ...errors].join('\n');
    const prompt = `Fix the following C code issues:\n\n${issues}\n\nCurrent code:\n\`\`\`c\n${code}\n\`\`\`\n\nProvide only the corrected C code without explanations.`;

    try {
      const response = await axios.post(
        `${this.apiUrl}/chat/completions`,
        {
          model: 'gpt-4',
          messages: [
            {
              role: 'system',
              content: 'You are a C code expert. Fix all warnings and errors. Return only valid C code.'
            },
            {
              role: 'user',
              content: prompt
            }
          ],
          temperature: 0.2,
          max_tokens: 4000
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      return this.extractCodeFromResponse(response.data.choices[0].message.content);
    } catch (error: any) {
      throw new Error(`Failed to improve code: ${error.message}`);
    }
  }

  private buildPrompt(idea: string, characteristics: string[]): string {
    const charList = characteristics.join(', ');
    return `Generate production-ready C code that implements: "${idea}"

Requirements:
- Modular design with clear separation of concerns
- Fault-tolerant error handling
- Security best practices (input validation, bounds checking)
- Atomicity for critical operations
- Concurrent and parallel processing support
- Distributed system capabilities
- Cache-coherent memory operations
- Encrypted data handling
- Protocol-driven communication
- Robust error recovery
- Asynchronous I/O operations
- Producer-consumer patterns
- Synchronized access to shared resources
- Optimized for performance
- Lightweight and efficient

Characteristics to emphasize: ${charList}

Include:
- Proper header files
- Function prototypes
- Error handling
- Memory management
- Thread safety where applicable
- Comprehensive comments

Return only valid, compilable C code wrapped in \`\`\`c code blocks.`;
  }

  private extractCodeFromResponse(response: string): string {
    // Extract code from markdown code blocks
    const codeBlockRegex = /```(?:c|C)?\s*([\s\S]*?)```/;
    const match = response.match(codeBlockRegex);
    
    if (match && match[1]) {
      return match[1].trim();
    }
    
    // If no code block, try to extract code-like content
    const lines = response.split('\n');
    let inCode = false;
    let code: string[] = [];
    
    for (const line of lines) {
      if (line.trim().startsWith('#include') || line.trim().startsWith('//') || line.includes('{') || line.includes('}')) {
        inCode = true;
      }
      if (inCode) {
        code.push(line);
      }
    }
    
    return code.length > 0 ? code.join('\n') : response;
  }
}
