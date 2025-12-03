#!/bin/bash
# Test what Homebrew sees when extracting the archive

set -e

echo "Testing Homebrew archive extraction..."
cd /tmp
rm -rf test-homebrew-extraction
mkdir test-homebrew-extraction
cd test-homebrew-extraction

echo "Downloading archive..."
curl -sL "https://github.com/shyamalschandra/idea2circuit/archive/refs/tags/v0.0.1.tar.gz" -o archive.tar.gz

echo "Extracting..."
tar -xzf archive.tar.gz

echo ""
echo "Contents of extraction directory:"
ls -la

echo ""
echo "Looking for idea2circuit directories:"
ls -ld idea2circuit-* 2>/dev/null || echo "No idea2circuit-* directories found"

echo ""
echo "Looking for idea-to-circuit.zsh:"
find . -name "idea-to-circuit.zsh"

echo ""
echo "All directories:"
find . -type d -maxdepth 2

echo ""
echo "Testing cd into directory:"
cd idea2circuit-0.0.1
ls -la | head -20

echo ""
echo "Check if idea-to-circuit.zsh exists:"
if [ -f "idea-to-circuit.zsh" ]; then
    echo "✅ File exists!"
else
    echo "❌ File does not exist!"
fi
