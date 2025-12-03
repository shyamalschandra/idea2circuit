# Homebrew Tap for Flux Circuits

This repository contains the Homebrew formula for installing Flux Circuits via Homebrew.

## Installation

### 1. Tap this repository

```bash
brew tap shyamalschandra/idea2circuit
```

### 2. Install Flux Circuits

```bash
brew install flux-circuits
```

### 3. Configure API Keys

After installation, edit the configuration file:

```bash
nano ~/.flux-circuits/.env
```

Add your API keys:
```
CURSOR_API_KEY=your_cursor_api_key_here
CURSOR_API_URL=https://api.cursor.com/v1

FLUX_API_KEY=your_flux_api_key_here
FLUX_API_URL=https://api.flux.ai/v1
```

## Usage

```bash
flux-circuits "your idea here" TARGET
```

### Examples

```bash
# Generate an encrypted communication protocol for FPGA
flux-circuits "encrypted communication protocol with authentication" FPGA

# Create a parallel matrix multiplication circuit for GPU
flux-circuits "parallel matrix multiplication with cache optimization" GPU

# Build a quantum random number generator for QPU
flux-circuits "quantum random number generator" QPU
```

## Repository Structure

```
homebrew-idea2circuit/
└── flux-circuits.rb    # Homebrew formula
```

## Updating the Formula

When a new release is created on the main repository:

1. Download the release tarball
2. Calculate the SHA256: `shasum -a 256 flux-circuits-universal.tar.gz`
3. Update `flux-circuits.rb`:
   - Update the `version` field
   - Update the `sha256` field with the calculated value
   - Update the `url` if the release URL format changes

## Testing the Formula

```bash
# Test locally
brew install --build-from-source ./flux-circuits.rb

# Or test from the tap
brew tap shyamalschandra/idea2circuit
brew install --build-from-source flux-circuits
```

## License

Copyright (C) 2025, Shyamal Suhana Chandra
