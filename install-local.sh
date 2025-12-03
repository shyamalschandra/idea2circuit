#!/bin/bash
# Local installation script for Flux Circuits (bypasses Homebrew tap)
# This installs directly from the local source code

set -e

INSTALL_DIR="${HOME}/.local/flux-circuits"
BIN_DIR="${HOME}/.local/bin"

echo "🚀 Installing Flux Circuits locally..."
echo ""

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

# Copy files
echo "📦 Copying files..."
cp -r src "$INSTALL_DIR/"
cp -r dist "$INSTALL_DIR/" 2>/dev/null || echo "⚠️  dist/ not found, will build..."
cp package.json "$INSTALL_DIR/"
cp tsconfig.json "$INSTALL_DIR/"
cp .env.example "$INSTALL_DIR/"
cp idea-to-circuit.zsh "$INSTALL_DIR/"

# Build if needed
if [ ! -d "dist" ]; then
    echo "🔨 Building TypeScript..."
    npm install
    npm run build
    cp -r dist "$INSTALL_DIR/"
fi

# Install dependencies
echo "📥 Installing dependencies..."
cd "$INSTALL_DIR"
npm ci --production

# Create wrapper script
echo "📝 Creating wrapper script..."
cat > "$BIN_DIR/flux-circuits" << 'EOF'
#!/bin/bash
INSTALL_DIR="${HOME}/.local/flux-circuits"
ENV_FILE="${HOME}/.flux-circuits/.env"
ENV_EXAMPLE="${INSTALL_DIR}/.env.example"

# Create .env if it doesn't exist
if [ ! -f "${ENV_FILE}" ]; then
    mkdir -p "${HOME}/.flux-circuits"
    cp "${ENV_EXAMPLE}" "${ENV_FILE}"
    echo "Created ${ENV_FILE} from template. Please edit it and add your API keys."
fi

# Load environment variables
if [ -f "${ENV_FILE}" ]; then
    set -a
    source "${ENV_FILE}"
    set +a
fi

# Set up Node.js path
export NODE_PATH="${INSTALL_DIR}/node_modules:${NODE_PATH}"

# Run the script
cd "${INSTALL_DIR}"
exec zsh "${INSTALL_DIR}/idea-to-circuit.zsh" "$@"
EOF

chmod +x "$BIN_DIR/flux-circuits"

# Add to PATH if not already there
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo ""
    echo "⚠️  $BIN_DIR is not in your PATH"
    echo ""
    echo "Add this to your ~/.zshrc or ~/.bashrc:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    echo "Then run: source ~/.zshrc  (or source ~/.bashrc)"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Usage:"
echo "  flux-circuits \"your idea\" TARGET"
echo ""
echo "Configure API keys:"
echo "  nano ~/.flux-circuits/.env"
echo ""
