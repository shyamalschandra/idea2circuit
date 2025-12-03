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
    
    // Validate API key is configured
    if (!this.apiKey || this.apiKey.trim() === '' || this.apiKey === 'your_cursor_api_key_here') {
      throw new Error('CURSOR_API_KEY is not configured. Please set it in your .env file.');
    }
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
        // Handle authentication errors specifically
        if (error.response.status === 401 || error.response.status === 403) {
          throw new Error(`Cursor API authentication failed (${error.response.status}): Invalid or expired API key. Please check your CURSOR_API_KEY in .env`);
        }
        throw new Error(`Cursor API error: ${error.response.status} - ${error.response.data?.error?.message || 'Unknown error'}`);
      }
      throw new Error(`Failed to connect to Cursor API: ${error.message}`);
    }
  }

  /**
   * Improve code by fixing warnings and errors
   */
  async improveCode(code: string, warnings: string[], errors: string[]): Promise<string> {
    // Categorize issues for better prompting
    const criticalErrors = errors.filter(e => 
      e.toLowerCase().includes('error:') && 
      !e.toLowerCase().includes('warning')
    );
    
    const syntaxErrors = criticalErrors.filter(e => 
      e.toLowerCase().includes('syntax') || 
      e.toLowerCase().includes('expected') ||
      e.toLowerCase().includes('parse')
    );
    
    const semanticErrors = criticalErrors.filter(e => 
      e.toLowerCase().includes('undeclared') || 
      e.toLowerCase().includes('undefined') ||
      e.toLowerCase().includes('type')
    );

    // Build detailed prompt with categorized issues
    let prompt = `You are fixing C code compilation issues. Here's what needs to be fixed:\n\n`;
    
    if (syntaxErrors.length > 0) {
      prompt += `SYNTAX ERRORS (fix these first):\n`;
      syntaxErrors.forEach((err, i) => {
        prompt += `${i + 1}. ${err}\n`;
      });
      prompt += '\n';
    }
    
    if (semanticErrors.length > 0) {
      prompt += `SEMANTIC/TYPE ERRORS:\n`;
      semanticErrors.forEach((err, i) => {
        prompt += `${i + 1}. ${err}\n`;
      });
      prompt += '\n';
    }
    
    const otherErrors = criticalErrors.filter(e => 
      !syntaxErrors.includes(e) && !semanticErrors.includes(e)
    );
    
    if (otherErrors.length > 0) {
      prompt += `OTHER ERRORS:\n`;
      otherErrors.forEach((err, i) => {
        prompt += `${i + 1}. ${err}\n`;
      });
      prompt += '\n';
    }
    
    if (warnings.length > 0) {
      prompt += `WARNINGS (fix if possible):\n`;
      warnings.slice(0, 5).forEach((warn, i) => {
        prompt += `${i + 1}. ${warn}\n`;
      });
      prompt += '\n';
    }
    
    prompt += `Current code:\n\`\`\`c\n${code}\n\`\`\`\n\n`;
    prompt += `Instructions:\n`;
    prompt += `1. Fix all syntax errors first\n`;
    prompt += `2. Ensure all variables and functions are properly declared\n`;
    prompt += `3. Fix type mismatches and incompatibilities\n`;
    prompt += `4. Address warnings where reasonable\n`;
    prompt += `5. Preserve the original functionality and logic\n`;
    prompt += `6. Add necessary #include directives if missing\n\n`;
    prompt += `Provide ONLY the corrected C code wrapped in \`\`\`c code blocks. No explanations.`;

    try {
      const response = await axios.post(
        `${this.apiUrl}/chat/completions`,
        {
          model: 'gpt-4',
          messages: [
            {
              role: 'system',
              content: 'You are an expert C programmer. Fix compilation errors systematically. Return only valid, compilable C code in markdown code blocks.'
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

      const improvedCode = this.extractCodeFromResponse(response.data.choices[0].message.content);
      
      // Validate that we got actual code back
      if (!improvedCode || improvedCode.length < 10) {
        throw new Error('Received invalid or empty code from API');
      }
      
      return improvedCode;
    } catch (error: any) {
      if (error.response) {
        // Handle authentication errors specifically
        if (error.response.status === 401 || error.response.status === 403) {
          throw new Error(`Cursor API authentication failed (${error.response.status}): Invalid or expired API key. Please check your CURSOR_API_KEY in .env`);
        }
        
        // Handle rate limiting
        if (error.response.status === 429) {
          throw new Error(`Cursor API rate limit exceeded. Please wait a moment and try again.`);
        }
        
        // Handle other API errors
        const errorDetail = error.response.data?.error?.message || error.response.statusText || 'Unknown error';
        throw new Error(`Cursor API error (${error.response.status}): ${errorDetail}`);
      }
      
      // Handle network errors
      if (error.code === 'ECONNREFUSED' || error.code === 'ENOTFOUND') {
        throw new Error(`Cannot connect to Cursor API at ${this.apiUrl}. Please check your network connection and CURSOR_API_URL setting.`);
      }
      
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
