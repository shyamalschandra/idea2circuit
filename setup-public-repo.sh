#!/bin/bash
# Script to help set up public repository and Homebrew tap
# Run this AFTER making your repository public on GitHub

set -e

VERSION="0.0.1"
REPO_OWNER="shyamalschandra"
REPO_NAME="idea2circuit"
TAP_NAME="homebrew-flux-circuits"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Flux Circuits - Public Repository Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Check if repo is public
echo "📋 Step 1: Checking if repository is public..."
echo ""
echo "⚠️  IMPORTANT: Before continuing, make sure you have:"
echo "   1. Made your repository public on GitHub"
echo "   2. Reviewed all files for sensitive information"
echo "   3. Checked your .gitignore is correct"
echo ""
read -p "Have you made the repository public? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo ""
    echo "❌ Please make the repository public first:"
    echo "   https://github.com/${REPO_OWNER}/${REPO_NAME}/settings"
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Step 2: Create and push tag
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Step 2: Creating Git tag v${VERSION}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if tag already exists
if git tag -l | grep -q "v${VERSION}"; then
    echo "⚠️  Tag v${VERSION} already exists"
    read -p "Delete and recreate? (yes/no): " DELETE_TAG
    if [ "$DELETE_TAG" = "yes" ]; then
        git tag -d "v${VERSION}"
        git push origin ":refs/tags/v${VERSION}" 2>/dev/null || true
        echo "✅ Old tag deleted"
    else
        echo "ℹ️  Using existing tag"
    fi
fi

# Create tag if it doesn't exist
if ! git tag -l | grep -q "v${VERSION}"; then
    git tag -a "v${VERSION}" -m "Initial release: Flux Circuits v${VERSION}"
    echo "✅ Created tag v${VERSION}"
fi

# Push tag
echo "📤 Pushing tag to GitHub..."
git push origin "v${VERSION}"
echo "✅ Tag pushed"

# Step 3: Wait for GitHub to process
echo ""
echo "⏳ Waiting 5 seconds for GitHub to process the tag..."
sleep 5

# Step 4: Download and calculate SHA256
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔐 Step 3: Calculating SHA256 hash"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/tags/v${VERSION}.tar.gz"
TEMP_FILE=$(mktemp).tar.gz

echo "📥 Downloading: ${ARCHIVE_URL}"
if curl -L -f -o "${TEMP_FILE}" "${ARCHIVE_URL}"; then
    echo "✅ Downloaded successfully"
else
    echo ""
    echo "❌ Failed to download archive!"
    echo "   This usually means:"
    echo "   1. Repository is not public yet (wait a few minutes)"
    echo "   2. Tag wasn't pushed correctly"
    echo "   3. Network issue"
    echo ""
    echo "   Try manually:"
    echo "   curl -L '${ARCHIVE_URL}'"
    rm -f "${TEMP_FILE}"
    exit 1
fi

echo ""
echo "🔐 Calculating SHA256..."
SHA256=$(shasum -a 256 "${TEMP_FILE}" | cut -d' ' -f1)
echo "✅ SHA256: ${SHA256}"

# Clean up
rm -f "${TEMP_FILE}"

# Step 5: Update formula
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Step 4: Updating formula with SHA256"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Update the formula file
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/sha256 \".*\"/sha256 \"${SHA256}\"/" flux-circuits.rb
else
    sed -i "s/sha256 \".*\"/sha256 \"${SHA256}\"/" flux-circuits.rb
fi

echo "✅ Updated flux-circuits.rb with SHA256"

# Commit the change
git add flux-circuits.rb
git commit -m "Update formula SHA256 for v${VERSION} release" || echo "ℹ️  No changes to commit"
git push origin main
echo "✅ Changes committed and pushed"

# Step 6: Instructions for tap setup
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🍺 Step 5: Set up Homebrew Tap"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next, you need to create a PUBLIC tap repository:"
echo ""
echo "1. Create a new repository on GitHub:"
echo "   Name: ${TAP_NAME}"
echo "   Visibility: PUBLIC"
echo "   URL: https://github.com/new"
echo ""
echo "2. Then run these commands:"
echo ""
echo "   cd ~/projects  # or your preferred location"
echo "   git clone https://github.com/${REPO_OWNER}/${TAP_NAME}.git"
echo "   cd ${TAP_NAME}"
echo "   mkdir Formula"
echo "   cp $(pwd)/flux-circuits.rb Formula/"
echo "   git add Formula/flux-circuits.rb"
echo "   git commit -m 'Add flux-circuits formula'"
echo "   git push origin main"
echo ""
echo "3. Test the installation:"
echo ""
echo "   brew tap ${REPO_OWNER}/flux-circuits"
echo "   brew install flux-circuits"
echo "   flux-circuits --help"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Summary:"
echo "   ✅ Tag v${VERSION} created and pushed"
echo "   ✅ SHA256 calculated: ${SHA256}"
echo "   ✅ Formula updated and committed"
echo "   📋 Next: Create public tap repository (see instructions above)"
echo ""
