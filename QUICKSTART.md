# Quick Start Guide

## Prerequisites Check

Before running the script, ensure you have:

1. **Node.js and npm** installed:
   ```bash
   node --version  # Should be v18+
   npm --version   # Should be v9+
   ```

2. **gcc** compiler installed:
   ```bash
   gcc --version
   ```

3. **zsh** shell (default on macOS):
   ```bash
   zsh --version
   ```

## Setup (One-Time)

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure API keys:**
   ```bash
   cp .env.example .env
   # Edit .env and add your API keys
   ```

3. **Build the project:**
   ```bash
   npm run build
   ```

## Running Your First Conversion

```bash
./idea-to-circuit.zsh "encrypted message queue" FPGA
```

This will:
1. Generate C code for an encrypted message queue
2. Validate and improve the code recursively
3. Add copyright notice
4. Run comprehensive tests (20 per line)
5. Compile to FPGA circuit using Flux
6. Save all outputs to `output/` directory

## Example Ideas

### Simple Examples
```bash
# Basic encryption
./idea-to-circuit.zsh "AES encryption module" ASIC

# Parallel processing
./idea-to-circuit.zsh "parallel sorting algorithm" GPU

# Communication protocol
./idea-to-circuit.zsh "TCP-like reliable transport" FPGA
```

### Complex Examples
```bash
# Distributed system
./idea-to-circuit.zsh "distributed cache with consistency guarantees" ASIC

# Quantum computing
./idea-to-circuit.zsh "quantum error correction circuit" QPU

# Machine learning
./idea-to-circuit.zsh "neural network inference engine" TPU
```

## Understanding Output

After running, check the `output/` directory:

- `circuit_*_code.c` - Generated C code with copyright
- `circuit_*_tests.json` - All test results
- `circuit_*_circuit.json` - Hardware circuit schematic

## Troubleshooting

### "API key not found"
- Check that `.env` exists and contains valid API keys
- Verify API keys are active and have proper permissions

### "gcc not found"
- Install gcc: `brew install gcc` (macOS) or use your system's package manager

### "TypeScript compilation errors"
- Run `npm install` to ensure all dependencies are installed
- Run `npm run build` to rebuild

### "Flux API error"
- Verify your Flux API key is correct
- Check Flux API documentation for endpoint changes
- The script includes fallback mechanisms for API structure differences

## API Configuration Notes

### Cursor Headless CLI
The script uses the Cursor API for code generation. The actual endpoint structure may vary. If you encounter issues:

1. Check the [Cursor Headless CLI documentation](https://cursor.com/docs/cli/headless)
2. Update `src/cursor-client.ts` with the correct endpoint structure
3. Adjust the API request format if needed

### Flux API
The script uses the Flux API for hardware compilation. The actual endpoint structure may vary. If you encounter issues:

1. Check the [Flux API documentation](https://docs.flux.ai/reference/how-the-api-works)
2. Update `src/flux-client.ts` with the correct endpoint structure
3. The script includes a mock fallback for testing without API access

## Next Steps

- Experiment with different ideas and hardware targets
- Review generated code in `output/` directory
- Customize buzzword characteristics in `src/index.ts`
- Adjust test generation parameters in `src/test-generator.ts`
