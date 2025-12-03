#!/bin/bash
# Automated setup script to run AFTER making the repository public
# This verifies everything works and updates the Homebrew formula

set -e

echo "🚀 Setting Up Homebrew After Making Repository Public"
echo "======================================================"
echo ""

# Step 1: Wait a bit and verify
echo "1️⃣  Verifying repository is now public..."
echo "   (Waiting 3 seconds for GitHub to update...)"
sleep 3

# Run verification
./verify-homebrew-setup.sh

echo ""
echo "2️⃣  Checking if archives are accessible..."
TAG_URL="https://github.com/shyamalschandra/idea2circuit/archive/refs/tags/v0.0.1.tar.gz"
MAIN_URL="https://github.com/shyamalschandra/idea2circuit/archive/refs/heads/main.tar.gz"

TAG_WORKS=false
MAIN_WORKS=false

if curl -sI "$TAG_URL" | grep -q "200"; then
    echo "   ✅ Tag archive is accessible!"
    TAG_WORKS=true
else
    echo "   ⏳ Tag archive not ready yet (may need more time)"
fi

if curl -sI "$MAIN_URL" | grep -q "200"; then
    echo "   ✅ Main branch archive is accessible!"
    MAIN_WORKS=true
else
    echo "   ⏳ Main branch archive not ready yet"
fi

if [ "$TAG_WORKS" = false ] && [ "$MAIN_WORKS" = false ]; then
    echo ""
    echo "⚠️  Archives not ready yet. This is normal - GitHub can take 2-5 minutes."
    echo ""
    read -p "Wait and retry? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Waiting 30 seconds..."
        sleep 30
        if curl -sI "$TAG_URL" | grep -q "200"; then
            TAG_WORKS=true
            echo "   ✅ Tag archive is now accessible!"
        fi
        if curl -sI "$MAIN_URL" | grep -q "200"; then
            MAIN_WORKS=true
            echo "   ✅ Main branch archive is now accessible!"
        fi
    fi
fi

# Step 2: Update formula URL if tag works
if [ "$TAG_WORKS" = true ]; then
    echo ""
    echo "3️⃣  Updating formula to use tag URL..."
    sed -i '' 's|url "https://github.com/shyamalschandra/idea2circuit/archive/refs/heads/main.tar.gz"|url "https://github.com/shyamalschandra/idea2circuit/archive/refs/tags/v#{version}.tar.gz"|' flux-circuits.rb
    sed -i '' 's|# Using main branch for now|# Using tag URL|' flux-circuits.rb
    sed -i '' 's|# Tag URL: "https://github.com/shyamalschandra/idea2circuit/archive/refs/tags/v#{version}.tar.gz"||' flux-circuits.rb
    echo "   ✅ Formula updated to use tag URL"
elif [ "$MAIN_WORKS" = true ]; then
    echo ""
    echo "3️⃣  Formula already uses main branch URL (this works!)"
else
    echo ""
    echo "⚠️  Archives still not accessible. You may need to:"
    echo "   - Wait a few more minutes"
    echo "   - Or verify the repository is actually public"
    echo ""
    echo "   Check: https://github.com/shyamalschandra/idea2circuit"
    echo "   (Should be visible without login)"
    exit 1
fi

# Step 3: Update tap repository
echo ""
echo "4️⃣  Updating Homebrew tap repository..."
TAP_DIR="${HOME}/homebrew-idea2circuit"

if [ ! -d "$TAP_DIR" ]; then
    echo "   📁 Creating tap directory..."
    mkdir -p "$TAP_DIR"
    cd "$TAP_DIR"
    git init
    git remote add origin "https://github.com/shyamalschandra/homebrew-idea2circuit.git" 2>/dev/null || \
        git remote set-url origin "https://github.com/shyamalschandra/homebrew-idea2circuit.git"
else
    cd "$TAP_DIR"
    echo "   📁 Using existing tap directory"
    git pull origin main 2>/dev/null || true
fi

# Copy formula
cp "/Users/shyamalchandra/Flux-Circuits/flux-circuits.rb" .

# Commit and push
echo "   📝 Committing changes..."
git add flux-circuits.rb
git commit -m "Update Flux Circuits formula - build from source" || echo "   (No changes to commit)"
git push origin main || echo "   ⚠️  Push failed - you may need to set up the remote or push manually"

echo ""
echo "✅ Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Install via Homebrew:"
echo "   brew tap shyamalschandra/idea2circuit"
echo "   brew install flux-circuits"
echo ""
echo "2. Test it:"
echo "   flux-circuits --help"
echo ""
