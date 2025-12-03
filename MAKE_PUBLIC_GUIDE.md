# Making Repository Public - Step by Step

## Steps to Make Repository Public

### 1. Go to Repository Settings
Open in your browser:
**https://github.com/shyamalschandra/idea2circuit/settings**

### 2. Scroll to Danger Zone
- Scroll all the way down to the bottom of the settings page
- Look for the red "Danger Zone" section

### 3. Change Visibility
- Click the **"Change visibility"** button
- Select **"Make public"**
- Type the repository name to confirm: `shyamalschandra/idea2circuit`
- Click **"I understand, change repository visibility"**

### 4. Wait for GitHub
- GitHub needs 2-5 minutes to:
  - Update repository visibility
  - Generate archive URLs
  - Make archives accessible

### 5. Verify It Worked
After waiting 2-3 minutes, run:
```bash
./verify-homebrew-setup.sh
```

You should see:
- ✅ Repository is accessible
- ✅ Tag archive is accessible (or main branch archive)

### 6. Update Homebrew Formula
Once verified, run:
```bash
./fix-homebrew-formula.sh
```

This will:
- Copy the formula to your tap repository
- Update it with the correct URL
- Commit and push the changes

### 7. Install via Homebrew
```bash
brew tap shyamalschandra/idea2circuit
brew install flux-circuits
```

## Quick Commands

After making it public and waiting 2-3 minutes:

```bash
# Verify
./verify-homebrew-setup.sh

# Fix formula
./fix-homebrew-formula.sh

# Install
brew tap shyamalschandra/idea2circuit
brew install flux-circuits
```

## Troubleshooting

**If archives still return 404 after 5 minutes:**
- Try the alternative URL format
- Or wait a bit longer (GitHub can be slow)

**If you see "Repository not found":**
- Double-check the repository name
- Ensure you clicked "Make public" (not "Make private")

**If verification shows everything works but install fails:**
- Check that your tap repository is also public
- Verify the formula was updated correctly
