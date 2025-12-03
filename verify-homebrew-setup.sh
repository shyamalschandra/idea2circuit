#!/bin/bash
# Script to verify Homebrew setup and diagnose issues

set -e

REPO_URL="https://github.com/shyamalschandra/idea2circuit"
TAP_REPO="https://github.com/shyamalschandra/homebrew-idea2circuit"
VERSION="0.0.1"

echo "🔍 Verifying Homebrew Setup for Flux Circuits"
echo "=============================================="
echo ""

# Check 1: Repository accessibility
echo "1️⃣  Checking main repository accessibility..."
if curl -sI "$REPO_URL" | grep -q "200\|301\|302"; then
    echo "   ✅ Repository is accessible"
    REPO_ACCESSIBLE=true
else
    echo "   ❌ Repository returns 404 (may be private or doesn't exist)"
    echo "   💡 Solution: Make the repository public or use local installation"
    REPO_ACCESSIBLE=false
fi

# Check 2: Tag accessibility
echo ""
echo "2️⃣  Checking tag v${VERSION} accessibility..."
TAG_URL="${REPO_URL}/archive/refs/tags/v${VERSION}.tar.gz"
if curl -sI "$TAG_URL" | grep -q "200"; then
    echo "   ✅ Tag archive is accessible"
    TAG_ACCESSIBLE=true
else
    echo "   ❌ Tag archive returns 404"
    echo "   💡 Solution: Ensure tag v${VERSION} exists and repository is public"
    TAG_ACCESSIBLE=false
fi

# Check 3: Main branch accessibility
echo ""
echo "3️⃣  Checking main branch accessibility..."
MAIN_URL="${REPO_URL}/archive/refs/heads/main.tar.gz"
if curl -sI "$MAIN_URL" | grep -q "200"; then
    echo "   ✅ Main branch archive is accessible"
    MAIN_ACCESSIBLE=true
else
    echo "   ❌ Main branch archive returns 404"
    MAIN_ACCESSIBLE=false
fi

# Check 4: Tap repository
echo ""
echo "4️⃣  Checking Homebrew tap repository..."
if curl -sI "$TAP_REPO" | grep -q "200\|301\|302"; then
    echo "   ✅ Tap repository is accessible"
    TAP_ACCESSIBLE=true
else
    echo "   ❌ Tap repository returns 404"
    echo "   💡 Solution: Create the repository: $TAP_REPO"
    TAP_ACCESSIBLE=false
fi

# Check 5: Local tag existence
echo ""
echo "5️⃣  Checking local git tags..."
if git tag -l | grep -q "^v${VERSION}$"; then
    echo "   ✅ Tag v${VERSION} exists locally"
    LOCAL_TAG=true
else
    echo "   ❌ Tag v${VERSION} not found locally"
    echo "   💡 Solution: Run: git tag v${VERSION} && git push origin v${VERSION}"
    LOCAL_TAG=false
fi

# Check 6: Remote tag existence
echo ""
echo "6️⃣  Checking remote git tags..."
if git ls-remote --tags origin 2>/dev/null | grep -q "refs/tags/v${VERSION}"; then
    echo "   ✅ Tag v${VERSION} exists on remote"
    REMOTE_TAG=true
else
    echo "   ❌ Tag v${VERSION} not found on remote"
    REMOTE_TAG=false
fi

# Summary and recommendations
echo ""
echo "📊 Summary"
echo "=========="
echo ""

if [ "$REPO_ACCESSIBLE" = true ] && [ "$TAG_ACCESSIBLE" = true ]; then
    echo "✅ Repository setup looks good! The formula should work."
    echo ""
    echo "Next steps:"
    echo "1. Update the formula in your tap repository"
    echo "2. Run: brew tap shyamalschandra/idea2circuit"
    echo "3. Run: brew install flux-circuits"
elif [ "$REPO_ACCESSIBLE" = false ]; then
    echo "⚠️  Repository is not accessible (likely private)"
    echo ""
    echo "Options:"
    echo "A) Make repository public (recommended for Homebrew)"
    echo "B) Use local installation (see install-local.sh)"
    echo "C) Use a different installation method"
elif [ "$TAG_ACCESSIBLE" = false ] && [ "$MAIN_ACCESSIBLE" = true ]; then
    echo "⚠️  Tag not accessible, but main branch is"
    echo ""
    echo "The formula is currently configured to use main branch."
    echo "This should work, but consider creating a release tag."
elif [ "$TAG_ACCESSIBLE" = false ] && [ "$MAIN_ACCESSIBLE" = false ]; then
    echo "❌ Neither tag nor main branch is accessible"
    echo ""
    echo "The repository appears to be private or doesn't exist."
    echo "Please make it public or use local installation."
fi

echo ""
echo "🔧 Quick Fixes"
echo "============="
if [ "$LOCAL_TAG" = false ]; then
    echo "• Create and push tag: git tag v${VERSION} && git push origin v${VERSION}"
fi
if [ "$REMOTE_TAG" = false ] && [ "$LOCAL_TAG" = true ]; then
    echo "• Push existing tag: git push origin v${VERSION}"
fi
if [ "$TAP_ACCESSIBLE" = false ]; then
    echo "• Create tap repository: https://github.com/new (name: homebrew-idea2circuit)"
fi

echo ""
