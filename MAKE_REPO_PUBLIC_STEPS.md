# Making Your Repository Public - Step by Step

## Overview

This guide will help you make your `idea2circuit` repository public so it works seamlessly with Homebrew.

## Prerequisites Checklist

Before making your repo public, review these items:

### ✅ Security Check
- [ ] No API keys or secrets in code
- [ ] No passwords in commit history
- [ ] No private credentials in `.env` files (we have `.env` in `.gitignore` ✓)
- [ ] No sensitive customer/business data
- [ ] No proprietary algorithms you want to protect

### ✅ Files to Review
- [ ] Check `.gitignore` is properly configured
- [ ] Verify `.env` is NOT committed (only `.env.example` should be)
- [ ] Review all files that will become public
- [ ] Check commit history for sensitive info

### ✅ Documentation
- [ ] README.md is clear and helpful
- [ ] LICENSE file exists
- [ ] API setup instructions are clear (API_SETUP_GUIDE.md ✓)

## Steps to Make Repository Public

### Step 1: Make Repository Public on GitHub

1. **Go to your repository settings:**
   ```
   https://github.com/shyamalschandra/idea2circuit/settings
   ```

2. **Scroll down to the "Danger Zone" section** (at the bottom)

3. **Click "Change visibility"**

4. **Select "Make public"**

5. **GitHub will ask you to confirm:**
   - Type the repository name: `idea2circuit`
   - Click "I understand, change repository visibility"

6. **Wait 2-3 minutes** for GitHub to process the change

### Step 2: Create a Git Tag for v0.0.1

After making the repo public, create a release tag:

```bash
cd /Users/shyamalchandra/Flux-Circuits

# Create and push the tag
git tag -a v0.0.1 -m "Initial release: Flux Circuits v0.0.1"
git push origin v0.0.1
```

### Step 3: Calculate SHA256 for Formula

Once the tag is pushed, GitHub creates a source archive. Calculate its SHA256:

```bash
# Download the archive
curl -L -o v0.0.1.tar.gz https://github.com/shyamalschandra/idea2circuit/archive/refs/tags/v0.0.1.tar.gz

# Calculate SHA256
shasum -a 256 v0.0.1.tar.gz

# Copy the hash (first part before the filename)
```

### Step 4: Update the Formula

1. Open `flux-circuits.rb`

2. Replace the placeholder SHA256:
   ```ruby
   sha256 "PLACEHOLDER_UPDATE_AFTER_MAKING_REPO_PUBLIC_AND_CREATING_TAG"
   ```
   
   With the actual hash from Step 3:
   ```ruby
   sha256 "abc123def456..."  # Your actual SHA256 hash
   ```

3. Save the file

### Step 5: Commit and Push the Updated Formula

```bash
git add flux-circuits.rb
git commit -m "Update formula SHA256 for v0.0.1 release"
git push origin main
```

### Step 6: Create Public Homebrew Tap

1. **Create a new public repository on GitHub:**
   - Repository name: `homebrew-flux-circuits`
   - Description: `Homebrew tap for Flux Circuits`
   - Visibility: **Public** ✓
   - Do NOT initialize with README (we'll add files)

2. **Clone and set up the tap:**
   ```bash
   cd ~/projects  # or wherever you keep repos
   git clone https://github.com/shyamalschandra/homebrew-flux-circuits.git
   cd homebrew-flux-circuits
   
   # Create Formula directory
   mkdir Formula
   
   # Copy the formula
   cp /Users/shyamalchandra/Flux-Circuits/flux-circuits.rb Formula/flux-circuits.rb
   
   # Create README
   cat > README.md << 'EOF'
   # Homebrew Tap for Flux Circuits
   
   Convert ideas into hardware circuits via C code generation.
   
   ## Installation
   
   ```bash
   brew tap shyamalschandra/flux-circuits
   brew install flux-circuits
   ```
   
   ## Usage
   
   ```bash
   flux-circuits "your idea here" ASIC
   ```
   
   Available targets: ASIC, FPGA, TPU, QPU, OPU, LPU, GPU
   
   ## Requirements
   
   - macOS 13.0+ (Ventura or later)
   - Node.js (installed automatically via Homebrew)
   - GCC (installed automatically via Homebrew)
   
   ## Configuration
   
   After installation, edit your API keys:
   
   ```bash
   nano ~/.flux-circuits/.env
   ```
   
   See [API Setup Guide](https://github.com/shyamalschandra/idea2circuit/blob/main/API_SETUP_GUIDE.md) for details.
   
   ## Repository
   
   Source code: https://github.com/shyamalchandra/idea2circuit
   EOF
   
   # Commit and push
   git add Formula/flux-circuits.rb README.md
   git commit -m "Initial tap setup with flux-circuits formula"
   git push origin main
   ```

### Step 7: Test the Installation

```bash
# Add your tap
brew tap shyamalschandra/flux-circuits

# Install
brew install flux-circuits

# Test it works
flux-circuits --help
```

### Step 8: Verify Everything Works

```bash
# Try a simple test
flux-circuits "simple counter" FPGA

# Check the installation
which flux-circuits
flux-circuits --version  # if you added version flag
```

## Troubleshooting

### Error: "Failed to download resource"
- Wait a few minutes after making repo public
- GitHub needs time to update CDN/caches
- Try: `brew update` then retry installation

### Error: "SHA256 mismatch"
- The archive changed or you calculated the hash incorrectly
- Re-download and recalculate the hash
- Update the formula with the correct hash

### Error: "Archive not found (404)"
- Make sure you pushed the tag: `git push origin v0.0.1`
- Check the tag exists: `git tag -l`
- Verify repo is public: https://github.com/shyamalschandra/idea2circuit

### Installation succeeds but command fails
- Check if `.env` file was created: `ls ~/.flux-circuits/`
- Add your API keys: `nano ~/.flux-circuits/.env`
- See API_SETUP_GUIDE.md for setup instructions

## Quick Command Reference

```bash
# Make repo public (manual step on GitHub)
# Then:

# Create tag
git tag -a v0.0.1 -m "Initial release"
git push origin v0.0.1

# Calculate SHA256
curl -L -o v0.0.1.tar.gz https://github.com/shyamalschandra/idea2circuit/archive/refs/tags/v0.0.1.tar.gz
shasum -a 256 v0.0.1.tar.gz

# Update formula (edit flux-circuits.rb with the SHA256)

# Create tap repo
# (Manual: Create homebrew-flux-circuits on GitHub as public)

# Clone and setup tap
git clone https://github.com/shyamalschandra/homebrew-flux-circuits.git
cd homebrew-flux-circuits
mkdir Formula
cp /Users/shyamalchandra/Flux-Circuits/flux-circuits.rb Formula/
# Create README.md (see above)
git add .
git commit -m "Initial tap setup"
git push origin main

# Test installation
brew tap shyamalschandra/flux-circuits
brew install flux-circuits
flux-circuits --help
```

## After Going Public

### Advantages:
✅ Simple Homebrew installation (one command)
✅ Automatic updates with `brew upgrade`
✅ No manual release process needed
✅ Standard open-source workflow
✅ Community can contribute (if you want)
✅ Easier to share and demonstrate

### What Changes:
- Anyone can view your source code
- Anyone can clone your repository
- Commit history is public
- Issues and PRs are public

### What Stays Private:
- Your local `.env` file (never committed)
- Any files in `.gitignore`
- Private discussions (unless you make issues)
- Your development machine

## Need to Go Back to Private?

If you need to make the repo private again later:
1. Go to repository settings
2. Scroll to "Danger Zone"
3. Click "Change visibility" → "Make private"
4. Note: This will break Homebrew installation for users

## Summary

Once you complete these steps:
- ✅ Your repo is public
- ✅ Homebrew tap is set up
- ✅ Users can install with: `brew install flux-circuits`
- ✅ Formula automatically builds from source

**Ready? Start with Step 1 above! 🚀**
