# Homebrew formula for Flux Circuits
# This formula downloads from GitHub Releases (works with private repositories!)
# To use this formula, place it in your Homebrew tap repository:
# https://github.com/shyamalschandra/homebrew-flux-circuits

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
  
  # Download from GitHub Releases (assets are public even from private repos)
  # When you create a release, the tarball will be publicly accessible
  url "https://github.com/shyamalschandra/idea2circuit/releases/download/v#{version}/flux-circuits-v#{version}.tar.gz"
  sha256 "PLACEHOLDER_UPDATE_AFTER_CREATING_RELEASE"
  
  def install
    # Debug: Print current directory and contents
    ohai "Current directory: #{Dir.pwd}"
    ohai "Directory contents: #{Dir.glob('*').join(', ')}"
    ohai "idea-to-circuit.zsh exists: #{File.exist?('idea-to-circuit.zsh')}"
    
    # GitHub archives extract to a versioned directory (e.g., idea2circuit-0.0.1)
    # Find and cd into that directory
    # Check if we're already in the right directory
    unless File.exist?("idea-to-circuit.zsh")
      ohai "File not found in current directory, searching subdirectories..."
      extracted_dir = Dir.glob("idea2circuit-*").find { |d| File.directory?(d) }
      if extracted_dir.nil?
        # Fallback: try to find any directory that contains idea-to-circuit.zsh
        extracted_dir = Dir.glob("*").find { |d| File.directory?(d) && File.exist?(File.join(d, "idea-to-circuit.zsh")) }
      end
      raise "Could not find extracted directory. Current dir: #{Dir.pwd}, Contents: #{Dir.glob('*').inspect}" unless extracted_dir
      ohai "Changing to directory: #{extracted_dir}"
      cd extracted_dir
      ohai "New directory: #{Dir.pwd}"
      ohai "New contents: #{Dir.glob('*').join(', ')}"
    end
    
    # Install all dependencies (needed for build)
    system "npm", "ci"
    
    # Build TypeScript
    system "npm", "run", "build"
    
    # Prune to production dependencies only
    system "npm", "prune", "--production"
    
    # Install the zsh script
    bin.install "idea-to-circuit.zsh"
    
    # Install compiled JavaScript files
    libexec.install "dist"
    
    # Install source files (needed for runtime)
    libexec.install "src"
    
    # Install package.json and tsconfig.json (needed for Node.js module resolution)
    libexec.install "package.json"
    libexec.install "tsconfig.json"
    
    # Install node_modules (production dependencies)
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
