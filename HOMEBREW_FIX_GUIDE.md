# Homebrew Installation Fix Guide

## Current Issue

The Homebrew formula is trying to download from GitHub, but the archive URLs return 404. This can happen if:
1. The repository is private (Homebrew requires public repos for archive downloads)
2. GitHub hasn't generated the archive yet (can take a few minutes after creating a tag)
3. The repository has restrictions on archive downloads

## Solutions

### ✅ Solution 1: Make Repository Public (Recommended)

If your repository is private, make it public:

1. Go to: https://github.com/shyamalschandra/idea2circuit/settings
2. Scroll down to "Danger Zone"
3. Click "Change visibility" → "Make public"
4. Wait 2-3 minutes for GitHub to generate archives
5. Run: `./verify-homebrew-setup.sh` to verify
6. Update your tap: `./fix-homebrew-formula.sh`
7. Install: `brew tap shyamalschandra/idea2circuit && brew install flux-circuits`

### ✅ Solution 2: Use Local Installation (Quick Fix)

If you want to test immediately without making the repo public:

```bash
./install-local.sh
```

This installs directly to `~/.local/bin/flux-circuits` without using Homebrew.

### ✅ Solution 3: Wait and Retry

Sometimes GitHub takes a few minutes to generate archive URLs after:
- Creating a new repository
- Pushing a new tag
- Changing repository visibility

Wait 5-10 minutes, then run:
```bash
./verify-homebrew-setup.sh
```

### ✅ Solution 4: Use a Different URL Format

If archives still don't work, try updating the formula to use a different URL format. Edit `flux-circuits.rb`:

```ruby
# Try this alternative format:
url "https://github.com/shyamalschandra/idea2circuit/archive/v0.0.1.tar.gz"
```

## Step-by-Step Fix Process

### Step 1: Verify Current Status
```bash
./verify-homebrew-setup.sh
```

### Step 2: Fix Based on Results

**If repository is private:**
- Make it public (see Solution 1)

**If repository is public but archives don't work:**
- Wait 5-10 minutes
- Run verification again
- If still failing, use Solution 2 (local install)

**If everything is accessible:**
- Run: `./fix-homebrew-formula.sh`
- Then install: `brew install flux-circuits`

### Step 3: Update Tap Repository

```bash
./fix-homebrew-formula.sh
```

This script will:
- Copy the updated formula to your tap repository
- Check which URL works (tag vs main branch)
- Update the formula accordingly
- Commit and push (if you confirm)

### Step 4: Test Installation

```bash
brew tap shyamalschandra/idea2circuit
brew install flux-circuits
flux-circuits --help
```

## Troubleshooting

### Error: "Failed to download resource"
- Repository is likely private → Make it public
- Or archives not generated yet → Wait and retry

### Error: "Repository not found"
- Check the repository URL is correct
- Verify the repository exists and is accessible

### Error: "Tag not found"
- Ensure tag exists: `git tag -l`
- Push tag if needed: `git push origin v0.0.1`

### Formula works but installation fails
- Check dependencies: `brew install node gcc`
- Review build logs: `brew install --verbose flux-circuits`

## Quick Reference

| Issue | Solution |
|-------|----------|
| Repository 404 | Make repository public |
| Archive 404 | Wait 5-10 min or use local install |
| Tag not found | Create/push tag: `git tag v0.0.1 && git push origin v0.0.1` |
| Need quick test | Use `./install-local.sh` |
| Everything works | Run `./fix-homebrew-formula.sh` then `brew install` |

## Current Formula Status

The formula is currently configured to:
- ✅ Build from source (not download binary)
- ✅ Use main branch URL (will switch to tag if available)
- ✅ Auto-install dependencies (node, gcc)
- ✅ Create `.env` file automatically

The formula should work once the repository archives are accessible!
