# Homebrew Setup Checklist

Use this checklist to set up Homebrew installation for Flux Circuits.

## Prerequisites

- [ ] GitHub repository exists: `https://github.com/shyamalschandra/idea2circuit`
- [ ] You have push access to the repository
- [ ] You have a GitHub account with access to create repositories

## Step 1: Create Homebrew Tap Repository

- [ ] Create new repository: `homebrew-idea2circuit`
  - Repository must be public
  - Name must be exactly `homebrew-idea2circuit`
  
- [ ] Clone the tap repository:
  ```bash
  git clone https://github.com/shyamalschandra/homebrew-idea2circuit.git
  cd homebrew-idea2circuit
  ```

- [ ] Copy the formula file:
  ```bash
  cp /path/to/Flux-Circuits/flux-circuits.rb .
  ```

- [ ] Commit and push:
  ```bash
  git add flux-circuits.rb
  git commit -m "Add Flux Circuits formula"
  git push origin main
  ```

## Step 2: Push Code to Main Repository

- [ ] Ensure all files are committed:
  ```bash
  cd /path/to/Flux-Circuits
  git add .
  git commit -m "Add Homebrew support"
  git push origin main
  ```

- [ ] Verify GitHub Actions workflow exists:
  - Check: `.github/workflows/release.yml` is in the repository

## Step 3: Create First Release

### Option A: Automated (Recommended)

- [ ] Create and push a version tag:
  ```bash
  git tag v0.0.1
  git push origin v0.0.1
  ```

- [ ] Wait for GitHub Actions to complete
  - Check: https://github.com/shyamalschandra/idea2circuit/actions

- [ ] Verify release was created:
  - Check: https://github.com/shyamalschandra/idea2circuit/releases
  - Should see `v0.0.1` release with `flux-circuits-universal.tar.gz`

### Option B: Manual

- [ ] Build the package locally:
  ```bash
  ./build-release.sh 0.0.1
  ```

- [ ] Create GitHub release manually:
  - Go to: https://github.com/shyamalschandra/idea2circuit/releases/new
  - Tag: `v0.0.1`
  - Title: `Release v0.0.1`
  - Upload: `flux-circuits-universal.tar.gz`

## Step 4: Update Homebrew Formula

- [ ] Get SHA256 from release:
  - Download the tarball from GitHub release
  - Calculate: `shasum -a 256 flux-circuits-universal.tar.gz`
  - Or copy from GitHub release page (if shown)

- [ ] Update `flux-circuits.rb` in tap repository:
  ```ruby
  version "0.0.1"
  sha256 "YOUR_SHA256_HERE"
  ```

- [ ] Commit and push:
  ```bash
  cd /path/to/homebrew-idea2circuit
  git add flux-circuits.rb
  git commit -m "Update to v0.0.1"
  git push origin main
  ```

## Step 5: Test Installation

- [ ] Tap the repository:
  ```bash
  brew tap shyamalschandra/idea2circuit
  ```

- [ ] Install:
  ```bash
  brew install flux-circuits
  ```

- [ ] Verify installation:
  ```bash
  which flux-circuits
  flux-circuits --help
  ```

- [ ] Configure API keys:
  ```bash
  nano ~/.flux-circuits/.env
  # Add your CURSOR_API_KEY and FLUX_API_KEY
  ```

- [ ] Test functionality:
  ```bash
  flux-circuits "test idea" FPGA
  ```

## Step 6: Update Documentation (Optional)

- [ ] Add Homebrew installation instructions to main README.md
- [ ] Update tap repository README if needed

## Troubleshooting

### Formula not found
- [ ] Verify tap repository is public
- [ ] Check repository name is exactly `homebrew-idea2circuit`
- [ ] Try: `brew tap --force shyamalschandra/idea2circuit`

### SHA256 mismatch
- [ ] Re-download tarball from release
- [ ] Recalculate SHA256
- [ ] Update formula and push again

### Installation fails
- [ ] Check dependencies: `brew install node gcc`
- [ ] Check Homebrew logs: `brew install --verbose flux-circuits`
- [ ] Verify tarball structure is correct

### Command not found after installation
- [ ] Check PATH: `echo $PATH | grep homebrew`
- [ ] Reload shell: `source ~/.zshrc` or restart terminal
- [ ] Verify installation: `brew list flux-circuits`

## Future Releases

For new versions (e.g., 0.0.2):

1. [ ] Update version in `package.json`
2. [ ] Create new tag: `git tag v0.0.2 && git push origin v0.0.2`
3. [ ] Wait for GitHub Actions to build release
4. [ ] Get SHA256 from new release
5. [ ] Update `flux-circuits.rb` in tap repository
6. [ ] Commit and push tap repository

## Success Criteria

✅ Users can install with: `brew tap shyamalschandra/idea2circuit && brew install flux-circuits`  
✅ `flux-circuits` command works after installation  
✅ `.env` file is auto-created in `~/.flux-circuits/`  
✅ All dependencies are properly installed  
✅ The tool functions correctly with API keys configured

---

**Need Help?** See `HOMEBREW_SETUP.md` for detailed instructions.
