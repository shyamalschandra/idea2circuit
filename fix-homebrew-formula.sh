#!/bin/bash
# Script to fix and update the Homebrew formula

set -e

FORMULA_FILE="flux-circuits.rb"
TAP_DIR="${HOME}/homebrew-idea2circuit"

echo "🔧 Fixing Homebrew Formula"
echo "========================="
echo ""

# Check if tap directory exists
if [ ! -d "$TAP_DIR" ]; then
    echo "📁 Tap directory not found. Creating..."
    mkdir -p "$TAP_DIR"
    cd "$TAP_DIR"
    git init
    git remote add origin "https://github.com/shyamalschandra/homebrew-idea2circuit.git" 2>/dev/null || \
        git remote set-url origin "https://github.com/shyamalschandra/homebrew-idea2circuit.git"
else
    cd "$TAP_DIR"
    echo "📁 Using existing tap directory: $TAP_DIR"
fi

# Copy the formula
echo "📋 Copying formula..."
cp "/Users/shyamalchandra/Flux-Circuits/$FORMULA_FILE" .

# Check if we should use a different URL
echo ""
echo "🔍 Checking repository archive accessibility..."

# Try tag URL
TAG_URL="https://github.com/shyamalschandra/idea2circuit/archive/refs/tags/v0.0.1.tar.gz"
if curl -sI "$TAG_URL" | grep -q "200"; then
    echo "✅ Tag archive is accessible - using tag URL"
    USE_TAG=true
else
    echo "❌ Tag archive not accessible"
    USE_TAG=false
fi

# Try main branch URL
MAIN_URL="https://github.com/shyamalschandra/idea2circuit/archive/refs/heads/main.tar.gz"
if curl -sI "$MAIN_URL" | grep -q "200"; then
    echo "✅ Main branch archive is accessible - using main branch URL"
    USE_MAIN=true
else
    echo "❌ Main branch archive not accessible"
    USE_MAIN=false
fi

# Update formula URL if needed
if [ "$USE_TAG" = true ]; then
    echo ""
    echo "📝 Updating formula to use tag URL..."
    sed -i '' 's|url "https://github.com/shyamalschandra/idea2circuit/archive/refs/heads/main.tar.gz"|url "https://github.com/shyamalschandra/idea2circuit/archive/refs/tags/v#{version}.tar.gz"|' "$FORMULA_FILE"
    sed -i '' 's|# Tag URL: "https://github.com/shyamalschandra/idea2circuit/archive/refs/tags/v#{version}.tar.gz"|# Using tag URL|' "$FORMULA_FILE"
elif [ "$USE_MAIN" = true ]; then
    echo ""
    echo "📝 Formula already uses main branch URL (this is fine)"
else
    echo ""
    echo "⚠️  WARNING: Neither archive URL is accessible!"
    echo "   The repository may be private or GitHub archives may not be available yet."
    echo "   Options:"
    echo "   1. Make the repository public"
    echo "   2. Wait a few minutes for GitHub to generate archives"
    echo "   3. Use local installation: ./install-local.sh"
fi

# Commit and push
echo ""
read -p "Commit and push to tap repository? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git add "$FORMULA_FILE"
    git commit -m "Update Flux Circuits formula - build from source" || echo "No changes to commit"
    git push origin main || echo "Push failed - you may need to set up the remote first"
    echo ""
    echo "✅ Formula updated in tap repository!"
    echo ""
    echo "Next steps:"
    echo "1. Test installation:"
    echo "   brew tap shyamalschandra/idea2circuit"
    echo "   brew install flux-circuits"
else
    echo ""
    echo "📝 Formula file updated locally. To push manually:"
    echo "   cd $TAP_DIR"
    echo "   git add flux-circuits.rb"
    echo "   git commit -m 'Update formula'"
    echo "   git push origin main"
fi

echo ""
