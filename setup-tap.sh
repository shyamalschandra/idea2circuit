#!/bin/bash
# Script to set up the Homebrew tap repository on GitHub
# Run this after creating the repository on GitHub

set -e

TAP_DIR="/Users/shyamalchandra/homebrew-idea2circuit"
REPO_URL="https://github.com/shyamalschandra/homebrew-idea2circuit.git"

echo "🚀 Setting up Homebrew tap repository..."

cd "$TAP_DIR"

# Check if remote already exists
if git remote get-url origin &>/dev/null; then
    echo "⚠️  Remote 'origin' already exists. Updating..."
    git remote set-url origin "$REPO_URL"
else
    echo "➕ Adding remote origin..."
    git remote add origin "$REPO_URL"
fi

# Ensure we're on main branch
git branch -M main

echo ""
echo "✅ Local repository is ready!"
echo ""
echo "Next steps:"
echo "1. Create the repository on GitHub:"
echo "   - Go to: https://github.com/new"
echo "   - Name: homebrew-idea2circuit"
echo "   - Visibility: PUBLIC (required)"
echo "   - DO NOT initialize with any files"
echo ""
echo "2. Push the repository:"
echo "   cd $TAP_DIR"
echo "   git push -u origin main"
echo ""
echo "3. Verify it's public and test:"
echo "   brew tap shyamalschandra/idea2circuit"
