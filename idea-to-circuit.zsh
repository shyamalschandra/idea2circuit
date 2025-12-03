#!/usr/bin/env zsh

# Idea to Circuit Converter
# A headless CLI-driven script that converts ideas into hardware circuits
# Copyright (C) 2025, Shyamal Suhana Chandra

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
# Support both Homebrew installation and direct execution
SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"

# Check if running from Homebrew installation
if [[ "$SCRIPT_DIR" == *"/opt/flux-circuits"* ]] || [[ "$SCRIPT_DIR" == *"/Cellar/flux-circuits"* ]]; then
    # Homebrew installation - use libexec directory
    PROJECT_DIR="$(dirname "$SCRIPT_DIR")/libexec"
else
    # Direct execution - use script directory
    PROJECT_DIR="$SCRIPT_DIR"
fi

# Configuration
MAX_RETRIES=5
OUTPUT_DIR="$PROJECT_DIR/output"
TEMP_DIR="/tmp/flux-circuits"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_DIR"

# Function to print colored output
print_info() {
    echo "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo "${RED}❌ $1${NC}"
}

print_header() {
    echo "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "${CYAN}$1${NC}"
    echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Function to check dependencies
check_dependencies() {
    print_info "Checking dependencies..."
    
    local missing_deps=()
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        missing_deps+=("node")
    else
        print_success "Node.js $(node --version) found"
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    else
        print_success "npm $(npm --version) found"
    fi
    
    # Check gcc
    if ! command -v gcc &> /dev/null; then
        missing_deps+=("gcc")
    else
        print_success "gcc $(gcc --version | head -n1) found"
    fi
    
    # Check TypeScript compiler
    if ! command -v tsc &> /dev/null && [ ! -f "$PROJECT_DIR/node_modules/.bin/tsc" ]; then
        print_warning "TypeScript compiler not found, will install dependencies"
    else
        print_success "TypeScript compiler found"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Please install missing dependencies and try again"
        exit 1
    fi
}

# Function to setup project
setup_project() {
    print_info "Setting up project..."
    
    cd "$PROJECT_DIR"
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        print_info "Installing npm dependencies..."
        npm install
        print_success "Dependencies installed"
    else
        print_success "Dependencies already installed"
    fi
    
    # Check if .env exists
    if [ ! -f ".env" ]; then
        print_warning ".env file not found"
        print_info "Creating .env from .env.example..."
        if [ -f ".env.example" ]; then
            cp .env.example .env
            print_warning "Please edit .env and add your API keys:"
            print_info "  - CURSOR_API_KEY"
            print_info "  - FLUX_API_KEY"
        else
            print_error ".env.example not found"
            exit 1
        fi
    fi
    
    # Build TypeScript
    if [ ! -d "dist" ] || [ "src" -nt "dist" ]; then
        print_info "Building TypeScript..."
        npm run build
        print_success "TypeScript compiled"
    else
        print_success "TypeScript already compiled"
    fi
}

# Function to validate input
validate_input() {
    local idea="$1"
    local target="$2"
    
    if [ -z "$idea" ]; then
        print_error "Idea cannot be empty"
        return 1
    fi
    
    local valid_targets=("ASIC" "FPGA" "TPU" "QPU" "OPU" "LPU" "GPU")
    local target_upper=$(echo "$target" | tr '[:lower:]' '[:upper:]')
    
    local valid=0
    for t in "${valid_targets[@]}"; do
        if [ "$t" = "$target_upper" ]; then
            valid=1
            break
        fi
    done
    
    if [ $valid -eq 0 ]; then
        print_error "Invalid target: $target"
        print_info "Valid targets: ${valid_targets[*]}"
        return 1
    fi
    
    return 0
}

# Function to run conversion
run_conversion() {
    local idea="$1"
    local target="$2"
    local target_upper=$(echo "$target" | tr '[:lower:]' '[:upper:]')
    
    print_header "🚀 IDEA TO CIRCUIT CONVERTER"
    
    print_info "Idea: ${MAGENTA}$idea${NC}"
    print_info "Target: ${MAGENTA}$target_upper${NC}"
    print_info "Max Retries: $MAX_RETRIES"
    
    # Generate timestamp for output files
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_prefix="$OUTPUT_DIR/circuit_${timestamp}"
    
    # Run the Node.js converter
    print_info "Starting conversion process..."
    
    cd "$PROJECT_DIR"
    
    # Capture output
    local output_file="${output_prefix}_output.log"
    local code_file="${output_prefix}_code.c"
    local circuit_file="${output_prefix}_circuit.json"
    local test_file="${output_prefix}_tests.json"
    
    # Run conversion and capture output
    if node dist/index.js "$idea" "$target_upper" 2>&1 | tee "$output_file"; then
        print_success "Conversion completed successfully!"
        
        # Extract code from output (if saved separately)
        # The Node.js script should save files, but we'll also parse from output
        print_info "Output saved to: $output_file"
        
        # Try to extract and save code
        if grep -q "Generated C Code:" "$output_file"; then
            # Extract code section
            awk '/Generated C Code:/,/Test Results Summary:/' "$output_file" | \
                sed '1d;$d' | sed '/^---/d' > "$code_file" || true
            print_success "C code saved to: $code_file"
        fi
        
        # Try to extract circuit
        if grep -q "Circuit Schematic:" "$output_file"; then
            awk '/Circuit Schematic:/,/Conversion complete!/' "$output_file" | \
                sed '1d;$d' | sed '/^---/d' > "$circuit_file" || true
            print_success "Circuit saved to: $circuit_file"
        fi
        
        print_header "📊 CONVERSION SUMMARY"
        print_success "All files saved to: $OUTPUT_DIR"
        print_info "  - Output log: $(basename "$output_file")"
        print_info "  - C code: $(basename "$code_file")"
        print_info "  - Circuit: $(basename "$circuit_file")"
        
        return 0
    else
        print_error "Conversion failed!"
        return 1
    fi
}

# Function to display usage
usage() {
    echo "Usage: $0 \"<idea>\" <target> [options]"
    echo ""
    echo "Arguments:"
    echo "  idea    - The idea or mashup of ideas to convert (in quotes)"
    echo "  target  - Hardware target: ASIC, FPGA, TPU, QPU, OPU, LPU, or GPU"
    echo ""
    echo "Options:"
    echo "  --retries N    - Maximum number of retry attempts (default: 5)"
    echo "  --output DIR   - Output directory (default: ./output)"
    echo "  --help         - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 \"encrypted communication protocol\" FPGA"
    echo "  $0 \"parallel matrix multiplication\" GPU"
    echo "  $0 \"quantum random number generator\" QPU"
    echo ""
    echo "Copyright (C) 2025, Shyamal Suhana Chandra"
}

# Main function
main() {
    # Parse arguments
    local idea=""
    local target=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                usage
                exit 0
                ;;
            --retries)
                MAX_RETRIES="$2"
                shift 2
                ;;
            --output)
                OUTPUT_DIR="$2"
                mkdir -p "$OUTPUT_DIR"
                shift 2
                ;;
            *)
                if [ -z "$idea" ]; then
                    idea="$1"
                elif [ -z "$target" ]; then
                    target="$1"
                else
                    print_error "Unexpected argument: $1"
                    usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate arguments
    if [ -z "$idea" ] || [ -z "$target" ]; then
        print_error "Missing required arguments"
        usage
        exit 1
    fi
    
    # Validate input
    if ! validate_input "$idea" "$target"; then
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Setup project
    setup_project
    
    # Run conversion
    if run_conversion "$idea" "$target"; then
        print_success "Process completed successfully!"
        exit 0
    else
        print_error "Process failed!"
        exit 1
    fi
}

# Run main function
main "$@"
