#!/bin/bash
# Build script for creating Homebrew binary package
# This script creates a tarball that can be used in the Homebrew formula

set -e

VERSION="${1:-0.0.1}"
PACKAGE_NAME="flux-circuits-package"
TARBALL_NAME="flux-circuits-universal.tar.gz"

echo "Building Flux Circuits release package v${VERSION}..."

# Clean previous builds
rm -rf "${PACKAGE_NAME}"
rm -f "${TARBALL_NAME}"

# Build TypeScript
echo "Building TypeScript..."
npm run build

# Install production dependencies only
echo "Installing production dependencies..."
npm ci --production
npm prune --production

# Create package directory structure
echo "Creating package structure..."
mkdir -p "${PACKAGE_NAME}/bin"
mkdir -p "${PACKAGE_NAME}/libexec"
mkdir -p "${PACKAGE_NAME}/etc/flux-circuits"

# Copy wrapper script
echo "Copying wrapper script..."
cp flux-circuits "${PACKAGE_NAME}/bin/"
chmod +x "${PACKAGE_NAME}/bin/flux-circuits"

# Copy zsh script
echo "Copying zsh script..."
cp idea-to-circuit.zsh "${PACKAGE_NAME}/bin/"
chmod +x "${PACKAGE_NAME}/bin/idea-to-circuit.zsh"

# Copy compiled files
echo "Copying compiled files..."
cp -r dist "${PACKAGE_NAME}/libexec/"
cp -r src "${PACKAGE_NAME}/libexec/"
cp package.json "${PACKAGE_NAME}/libexec/"
cp tsconfig.json "${PACKAGE_NAME}/libexec/"

# Copy node_modules
echo "Copying node_modules..."
cp -r node_modules "${PACKAGE_NAME}/libexec/"

# Copy .env.example
echo "Copying .env.example..."
cp .env.example "${PACKAGE_NAME}/etc/flux-circuits/"

# Create tarball
echo "Creating tarball..."
cd "${PACKAGE_NAME}"
tar -czf "../${TARBALL_NAME}" .
cd ..

# Calculate SHA256
SHA256=$(shasum -a 256 "${TARBALL_NAME}" | cut -d' ' -f1)

echo ""
echo "✅ Build complete!"
echo ""
echo "Package: ${TARBALL_NAME}"
echo "SHA256:  ${SHA256}"
echo ""
echo "To update the Homebrew formula, replace the sha256 with:"
echo "  sha256 \"${SHA256}\""
echo ""
echo "To test the package locally:"
echo "  tar -xzf ${TARBALL_NAME}"
echo "  ./bin/flux-circuits --help"
