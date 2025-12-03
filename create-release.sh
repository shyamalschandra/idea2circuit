#!/bin/bash
# Script to create a release tarball for Homebrew distribution
# This allows your main repo to stay private while releases are public

set -e

VERSION=${1:-0.0.1}
RELEASE_NAME="flux-circuits-v${VERSION}"
TARBALL="${RELEASE_NAME}.tar.gz"

echo "🔨 Creating release tarball for version ${VERSION}..."

# Create temporary directory for release files
TEMP_DIR=$(mktemp -d)
RELEASE_DIR="${TEMP_DIR}/${RELEASE_NAME}"

echo "📁 Setting up release directory..."
mkdir -p "${RELEASE_DIR}"

# Copy necessary files
echo "📋 Copying files..."
cp -r src "${RELEASE_DIR}/"
cp -r dist "${RELEASE_DIR}/" 2>/dev/null || echo "⚠️  dist/ not found, will build..."
cp package.json "${RELEASE_DIR}/"
cp package-lock.json "${RELEASE_DIR}/"
cp tsconfig.json "${RELEASE_DIR}/"
cp idea-to-circuit.zsh "${RELEASE_DIR}/"
cp .env.example "${RELEASE_DIR}/"
cp README.md "${RELEASE_DIR}/" 2>/dev/null || echo "ℹ️  No README.md found"
cp LICENSE "${RELEASE_DIR}/" 2>/dev/null || echo "ℹ️  No LICENSE found"

# Build if dist doesn't exist
if [ ! -d "${RELEASE_DIR}/dist" ]; then
    echo "🔨 Building TypeScript..."
    cd "${RELEASE_DIR}"
    npm ci
    npm run build
    cd -
else
    echo "✅ Using existing dist/"
    # Still need to install dependencies
    cd "${RELEASE_DIR}"
    npm ci --production
    cd -
fi

# Create tarball
echo "📦 Creating tarball..."
cd "${TEMP_DIR}"
tar -czf "${TARBALL}" "${RELEASE_NAME}"
cd -

# Move tarball to current directory
mv "${TEMP_DIR}/${TARBALL}" .

# Calculate SHA256
echo ""
echo "✅ Release tarball created: ${TARBALL}"
echo ""
echo "📊 Tarball size: $(du -h ${TARBALL} | cut -f1)"
echo ""
echo "🔐 SHA256 hash:"
SHA256=$(shasum -a 256 "${TARBALL}" | cut -d' ' -f1)
echo "   ${SHA256}"
echo ""

# Update formula file
echo "📝 Updating flux-circuits.rb with new SHA256..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/sha256 \".*\"/sha256 \"${SHA256}\"/" flux-circuits.rb
else
    sed -i "s/sha256 \".*\"/sha256 \"${SHA256}\"/" flux-circuits.rb
fi

# Cleanup
rm -rf "${TEMP_DIR}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 NEXT STEPS TO CREATE GITHUB RELEASE:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. Create a new release on GitHub:"
echo "   https://github.com/shyamalschandra/idea2circuit/releases/new"
echo ""
echo "2. Fill in the release details:"
echo "   - Tag: v${VERSION}"
echo "   - Title: Flux Circuits v${VERSION}"
echo "   - Description: (Add release notes)"
echo ""
echo "3. Upload the release asset:"
echo "   - Drag and drop: ${TARBALL}"
echo ""
echo "4. Publish the release"
echo ""
echo "5. The release asset will be PUBLIC even though your repo is PRIVATE!"
echo ""
echo "6. Test the installation:"
echo "   brew install flux-circuits"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Formula file updated with correct SHA256"
echo "✅ Ready to commit and push flux-circuits.rb"
echo ""
