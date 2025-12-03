# Homebrew formula for Flux Circuits
# This formula downloads pre-built binaries from GitHub Releases
# To use this formula, place it in your Homebrew tap repository:
# https://github.com/shyamalschandra/homebrew-idea2circuit

class FluxCircuits < Formula
  desc "Convert ideas into hardware circuits via C code generation"
  homepage "https://github.com/shyamalschandra/idea2circuit"
  version "0.0.1"
  license "Copyright (C) 2025, Shyamal Suhana Chandra"
  
  # Requires macOS 13.0+ (Ventura)
  depends_on :macos => :ventura
  
  # Dependencies
  depends_on "node"
  depends_on "gcc"
  
  # Determine architecture
  if Hardware::CPU.arm?
    arch = "arm64"
  else
    arch = "x86_64"
  end
  
  # Use universal binary if available, otherwise fall back to architecture-specific
  # Update these URLs after creating a GitHub release
  url "https://github.com/shyamalschandra/idea2circuit/releases/download/v#{version}/flux-circuits-universal.tar.gz"
  # Alternative: use architecture-specific binary
  # url "https://github.com/shyamalschandra/idea2circuit/releases/download/v#{version}/flux-circuits-#{arch}.tar.gz"
  
  # Calculate SHA256 after creating the release
  # Run: shasum -a 256 flux-circuits-universal.tar.gz
  # Note: This will be updated after the GitHub release is created with proper universal binary
  # Update this value after creating a GitHub release
  sha256 "PLACEHOLDER_SHA256_UPDATE_AFTER_RELEASE"
  
  def install
    # Install the zsh script
    bin.install "idea-to-circuit.zsh"
    
    # Install compiled JavaScript files
    libexec.install "dist"
    
    # Install source files (needed for runtime)
    libexec.install "src"
    
    # Install package.json and tsconfig.json (needed for Node.js module resolution)
    libexec.install "package.json"
    libexec.install "tsconfig.json"
    
    # Install node_modules (pre-installed dependencies)
    libexec.install "node_modules"
    
    # Install .env.example template
    (etc/"flux-circuits").install ".env.example"
    
    # Create wrapper script with correct Homebrew paths
    (bin/"flux-circuits").write <<~EOS
      #!/bin/bash
      # Flux Circuits wrapper script
      
      # Get the installation directory
      INSTALL_DIR="#{libexec}"
      
      # Set up Node.js path
      export NODE_PATH="${INSTALL_DIR}/node_modules:${NODE_PATH}"
      
      # Create .env from .env.example if it doesn't exist
      ENV_FILE="${HOME}/.flux-circuits/.env"
      ENV_EXAMPLE="#{etc}/flux-circuits/.env.example"
      
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
      
      # Run the zsh script with proper paths
      cd "${INSTALL_DIR}"
      exec zsh "#{bin}/idea-to-circuit.zsh" "$@"
    EOS
    
    # Make wrapper executable
    chmod 0755, bin/"flux-circuits"
  end
  
  def post_install
    # Create .env from .env.example in user's home directory if it doesn't exist
    env_file = "#{Dir.home}/.flux-circuits/.env"
    env_example = "#{etc}/flux-circuits/.env.example"
    
    unless File.exist?(env_file)
      system "mkdir", "-p", "#{Dir.home}/.flux-circuits"
      system "cp", env_example, env_file
      ohai "Created #{env_file} from template."
      ohai "Please edit it and add your API keys:"
      ohai "  - CURSOR_API_KEY"
      ohai "  - FLUX_API_KEY"
    end
  end
  
  test do
    # Test that the command exists and shows help
    system "#{bin}/flux-circuits", "--help"
  end
end
