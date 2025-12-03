# Homebrew Installation for Flux Circuits

This project can be installed via Homebrew using a custom tap.

## Quick Install

```bash
brew tap shyamalschandra/idea2circuit
brew install flux-circuits
```

## Setup

After installation, configure your API keys:

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

## Files Created

This setup creates the following files:

1. **Homebrew Formula**: `flux-circuits.rb` - The Homebrew formula file
2. **Wrapper Script**: `flux-circuits` - Main entry point script
3. **Build Script**: `build-release.sh` - Script to create release packages
4. **GitHub Actions**: `.github/workflows/release.yml` - Automated release workflow
5. **Documentation**: 
   - `HOMEBREW_SETUP.md` - Setup instructions
   - `HOMEBREW_TAP_README.md` - Tap repository README

## Next Steps

1. **Create the Homebrew tap repository**:
   - Create `https://github.com/shyamalschandra/homebrew-idea2circuit`
   - Copy `flux-circuits.rb` to that repository

2. **Create the first release**:
   - Push the code to `https://github.com/shyamalschandra/idea2circuit`
   - Tag a release: `git tag v0.0.1 && git push origin v0.0.1`
   - GitHub Actions will build and release automatically

3. **Update the formula**:
   - Get the SHA256 from the release
   - Update `flux-circuits.rb` in the tap repository with the SHA256
   - Commit and push

4. **Test installation**:
   ```bash
   brew tap shyamalschandra/idea2circuit
   brew install flux-circuits
   ```

See `HOMEBREW_SETUP.md` for detailed instructions.
