# Homebrew Setup Instructions

This document explains how to set up the Homebrew tap for Flux Circuits.

## Prerequisites

1. A GitHub repository at `https://github.com/shyamalschandra/idea2circuit`
2. A Homebrew tap repository at `https://github.com/shyamalschandra/homebrew-idea2circuit`

## Step 1: Create the Homebrew Tap Repository

1. Create a new repository on GitHub: `homebrew-idea2circuit`
   - Repository name must start with `homebrew-`
   - Make it public (Homebrew requires public taps)

2. Clone the repository:
   ```bash
   git clone https://github.com/shyamalschandra/homebrew-idea2circuit.git
   cd homebrew-idea2circuit
   ```

3. Copy the formula file:
   ```bash
   cp /path/to/Flux-Circuits/flux-circuits.rb .
   ```

4. Commit and push:
   ```bash
   git add flux-circuits.rb
   git commit -m "Add Flux Circuits formula"
   git push origin main
   ```

## Step 2: Create the First Release

### Option A: Using GitHub Actions (Recommended)

1. Push the release workflow to your main repository:
   ```bash
   cd /path/to/Flux-Circuits
   git add .github/workflows/release.yml
   git commit -m "Add GitHub Actions release workflow"
   git push origin main
   ```

2. Create a tag and push it:
   ```bash
   git tag v0.0.1
   git push origin v0.0.1
   ```

3. The GitHub Actions workflow will automatically:
   - Build the binary package
   - Create a GitHub release
   - Upload the tarball

### Option B: Manual Build

1. Build the release package:
   ```bash
   cd /path/to/Flux-Circuits
   ./build-release.sh 0.0.1
   ```

2. Create a GitHub release:
   - Go to https://github.com/shyamalschandra/idea2circuit/releases/new
   - Tag: `v0.0.1`
   - Title: `Release v0.0.1`
   - Upload `flux-circuits-universal.tar.gz`

3. Calculate SHA256:
   ```bash
   shasum -a 256 flux-circuits-universal.tar.gz
   ```

## Step 3: Update the Homebrew Formula

1. Update `flux-circuits.rb` in the tap repository:
   ```ruby
   version "0.0.1"
   sha256 "YOUR_CALCULATED_SHA256_HERE"
   ```

2. Commit and push:
   ```bash
   cd /path/to/homebrew-idea2circuit
   git add flux-circuits.rb
   git commit -m "Update to v0.0.1"
   git push origin main
   ```

## Step 4: Test Installation

```bash
# Tap the repository
brew tap shyamalschandra/idea2circuit

# Install
brew install flux-circuits

# Test
flux-circuits --help
```

## Updating for New Releases

1. Create a new release on the main repository (tag: `v0.0.2`, etc.)
2. Get the SHA256 from the release or calculate it
3. Update `flux-circuits.rb`:
   - Update `version`
   - Update `sha256`
4. Commit and push to the tap repository

## Troubleshooting

### Formula not found
- Ensure the tap repository is public
- Check that the repository name is exactly `homebrew-idea2circuit`

### SHA256 mismatch
- Recalculate the SHA256: `shasum -a 256 flux-circuits-universal.tar.gz`
- Ensure you're using the correct tarball from the release

### Installation fails
- Check that all dependencies are available: `node`, `gcc`
- Verify the tarball structure matches what the formula expects

## Formula File Location

The formula file `flux-circuits.rb` should be placed in the root of the `homebrew-idea2circuit` repository.
