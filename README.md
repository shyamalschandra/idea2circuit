# Flux Circuits - Idea to Circuit Converter

A headless CLI-driven zsh script that converts ideas or mashups of ideas into hardware circuits by first generating optimized C code, then compiling to various hardware targets using the Flux compiler.

**Copyright (C) 2025, Shyamal Suhana Chandra**

## Features

- 🚀 **Idea to Code**: Converts natural language ideas into production-ready C code
- 🔧 **Recursive Improvement**: Automatically fixes bugs and warnings through multiple iterations
- 🧪 **Comprehensive Testing**: Generates 20 tests per line of code (UX, regression, unit, blackbox, A-B)
- ⚡ **Hardware Compilation**: Compiles C code to hardware schematics for ASIC, FPGA, TPU, QPU, OPU, LPU, or GPU
- 🎨 **Design Pattern Validation**: Ensures code follows software engineering best practices
- 📝 **Copyright Injection**: Automatically adds copyright notice to generated code

## Requirements

- **Node.js** (v18 or higher)
- **npm** (v9 or higher)
- **gcc** (for C code validation)
- **zsh** (for the main script)
- **API Keys**:
  - Cursor Headless CLI API key
  - Flux API key

## Installation

1. Clone or navigate to the project directory:
```bash
cd Flux-Circuits
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env
```

4. Edit `.env` and add your API keys:
```
CURSOR_API_KEY=your_cursor_api_key_here
CURSOR_API_URL=https://api.cursor.com/v1

FLUX_API_KEY=your_flux_api_key_here
FLUX_API_URL=https://api.flux.ai/v1
```

5. Make the script executable:
```bash
chmod +x idea-to-circuit.zsh
```

## Usage

### Basic Usage

```bash
./idea-to-circuit.zsh "your idea here" TARGET
```

### Examples

```bash
# Generate an encrypted communication protocol for FPGA
./idea-to-circuit.zsh "encrypted communication protocol with authentication" FPGA

# Create a parallel matrix multiplication circuit for GPU
./idea-to-circuit.zsh "parallel matrix multiplication with cache optimization" GPU

# Build a quantum random number generator for QPU
./idea-to-circuit.zsh "quantum random number generator" QPU

# Design a distributed cache system for ASIC
./idea-to-circuit.zsh "distributed cache coherent memory system" ASIC
```

### Command Line Options

```bash
./idea-to-circuit.zsh "idea" TARGET [options]

Options:
  --retries N    Maximum number of retry attempts (default: 5)
  --output DIR   Output directory (default: ./output)
  --help         Show help message
```

### Hardware Targets

- **ASIC** - Application-Specific Integrated Circuit
- **FPGA** - Field-Programmable Gate Array
- **TPU** - Tensor Processing Unit
- **QPU** - Quantum Processing Unit
- **OPU** - Optical Processing Unit
- **LPU** - Language Processing Unit
- **GPU** - Graphics Processing Unit

## How It Works

1. **Code Generation**: Uses Cursor Headless CLI API to generate C code from your idea, incorporating buzzword characteristics:
   - Modular, fault-tolerant, secure
   - Atomicity, concurrent, parallel, distributed
   - Cache coherent, encrypted, protocol-driven
   - Robust, asynchronous, producer-consumer
   - Synchronized, optimized, lightweight

2. **Recursive Improvement**: Validates code using gcc and recursively improves it until it's bug-free and warning-free (up to N retries).

3. **Copyright Injection**: Adds copyright notice: "Copyright (C) 2025, Shyamal Suhana Chandra"

4. **Comprehensive Testing**: Generates and runs 20 tests per line of code:
   - UX tests (user experience, error messages, logging)
   - Regression tests (memory leaks, common bugs)
   - Unit tests (individual functions)
   - Blackbox tests (compilation, I/O)
   - A-B tests (optimization, alternative paths)

5. **Design Pattern Validation**: Checks for software engineering best practices and design patterns.

6. **Hardware Compilation**: Uses Flux API to compile the C code to a hardware schematic for the specified target.

7. **Output**: Saves all results to the `output/` directory with timestamps.

## Output Files

All output files are saved in the `output/` directory with timestamps:

- `circuit_YYYYMMDD_HHMMSS_output.log` - Complete conversion log
- `circuit_YYYYMMDD_HHMMSS_code.c` - Generated C code
- `circuit_YYYYMMDD_HHMMSS_circuit.json` - Circuit schematic
- `circuit_YYYYMMDD_HHMMSS_tests.json` - Test results

## Project Structure

```
Flux-Circuits/
├── src/
│   ├── index.ts              # Main converter class
│   ├── cursor-client.ts       # Cursor API integration
│   ├── flux-client.ts         # Flux API integration
│   ├── code-validator.ts      # Code validation and improvement
│   ├── test-generator.ts      # Test generation and execution
│   └── types.ts               # TypeScript type definitions
├── dist/                      # Compiled JavaScript (generated)
├── output/                    # Output files (generated)
├── idea-to-circuit.zsh        # Main zsh script
├── package.json               # Node.js dependencies
├── tsconfig.json              # TypeScript configuration
├── .env.example               # Environment variables template
└── README.md                  # This file
```

## API Configuration

### Cursor Headless CLI API

The script uses the Cursor Headless CLI API to generate and improve code. Configure your API key in `.env`:

```
CURSOR_API_KEY=your_key_here
CURSOR_API_URL=https://api.cursor.com/v1
```

### Flux API

The script uses the Flux API to compile C code to hardware circuits. Configure your API key in `.env`:

```
FLUX_API_KEY=your_key_here
FLUX_API_URL=https://api.flux.ai/v1
```

**Note**: The Flux API endpoints may need adjustment based on the actual Flux API documentation. The current implementation includes fallback mechanisms.

## Troubleshooting

### API Key Issues

If you see API authentication errors:
1. Verify your API keys in `.env`
2. Ensure the API URLs are correct
3. Check that your API keys have the necessary permissions

### Compilation Errors

If code generation fails:
1. Check that gcc is installed and in your PATH
2. Review the error messages in the output log
3. Try increasing `--retries` to allow more improvement attempts

### Missing Dependencies

If you see missing dependency errors:
```bash
npm install
npm run build
```

## Development

### Building

```bash
npm run build
```

### Running Directly (Node.js)

```bash
npm start "your idea" TARGET
```

Or with tsx for development:

```bash
npm run dev "your idea" TARGET
```

## License

**Copyright (C) 2025, Shyamal Suhana Chandra**

All rights reserved. This software is proprietary and confidential.

## Contributing

This is a private project. For questions or issues, please contact Shyamal Chandra.

## Acknowledgments

- Uses [Cursor Headless CLI](https://cursor.com/docs/cli/headless) for code generation
- Uses [Flux API](https://docs.flux.ai/reference/how-the-api-works) for hardware compilation
