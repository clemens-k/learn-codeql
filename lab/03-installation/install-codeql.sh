#!/bin/bash
# Script to install CodeQL CLI
# Usage: ./install-codeql.sh [version]
#   version: Optional. Specific CodeQL version to install (e.g., v2.20.1)
#            If not provided, installs the latest version.
#
# Required packages: curl tar grep gawk

set -e

SCRIPT_NAME=$(basename "$0")

# Parse command-line arguments
CODEQL_VERSION="${1:-latest}"

echo "🚀 CodeQL CLI Installation Script"
echo "=================================="
echo ""
echo "Version: $CODEQL_VERSION"
echo ""

# Configuration
CODEQL_HOME="$HOME/.codeql-home"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Function to create CodeQL folder
create_codeql_folder() {
    echo "📁 Creating CodeQL home directory..."
    
    if [ -f "$CODEQL_HOME/codeql/codeql" ]; then
        print_info "CodeQL CLI already exists at $CODEQL_HOME/codeql"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
        rm -rf "$CODEQL_HOME/codeql"
    fi
    
    mkdir -p "$CODEQL_HOME"
    print_success "Directory created: $CODEQL_HOME"
    echo ""
}

# Function to detect OS and set bundle name
detect_os() {
    echo "🔍 Detecting operating system..."
    local os=$(uname -s)
    
    case "$os" in
        Linux*)
            BUNDLE="codeql-bundle-linux64.tar.gz"
            ;;
        Darwin*)
            BUNDLE="codeql-bundle-osx64.tar.gz"
            ;;
        *)
            print_error "Unsupported OS: $os"
            exit 1
            ;;
    esac
    
    print_success "Detected: $os"
    print_info "Bundle: $BUNDLE"
    echo ""
}

# Function to fetch release with checksum verification
fetch_release() {
    local version="$1"
    local bundle="$2"
    
    echo "🌐 Fetching CodeQL release..."
    
    # Determine release URL
    if [ "$version" = "latest" ]; then
        local release_url="https://api.github.com/repos/github/codeql-action/releases/latest"
        print_info "Fetching latest release"
    else
        local release_url="https://api.github.com/repos/github/codeql-action/releases/tags/codeql-bundle-$version"
        print_info "Fetching release: $version"
    fi
    
    # Get download URL
    local download_url=$(curl -s "$release_url" | grep "browser_download_url.*$bundle\"" | cut -d '"' -f 4)
    
    if [ -z "$download_url" ]; then
        print_error "Failed to find download URL for $bundle"
        if [ "$version" != "latest" ]; then
            print_error "Version $version may not exist. Check available releases at:"
            print_error "https://github.com/github/codeql-action/releases"
        fi
        exit 1
    fi
    
    print_success "Found release"
    print_info "URL: $download_url"
    echo ""
    
    # Download bundle
    echo "⬇️  Downloading CodeQL CLI Bundle..."
    TMP_DIR=$(mktemp -d --tmpdir $SCRIPT_NAME.XXX )
    print_info "Temporary directory: $TMP_DIR"
    cd "$TMP_DIR"
    curl -L -o "$bundle" "$download_url"
    print_success "Downloaded to $TMP_DIR/$bundle"
    echo ""
    
    # Download and verify checksum
    echo "🔐 Downloading checksum file..."
    local checksum_url="${download_url}.checksum.txt"
    local checksum_file="${bundle}.checksum.txt"
    curl -L -o "$checksum_file" "$checksum_url"
    print_success "Downloaded checksum file"
    echo ""
    
    echo "🔍 Verifying checksum..."
    sha256sum --check "$checksum_file"
    print_success "Checksum verified successfully"
    echo ""
}

# Function to extract release
extract_release() {
    local tmp_dir="$1"
    local bundle="$2"
    
    echo "📦 Extracting CodeQL CLI..."
    cd "$CODEQL_HOME"
    tar -xzf "$tmp_dir/$bundle"
    print_success "Extracted to $CODEQL_HOME/codeql"
    echo ""
    
    # Cleanup
    rm -rf "$tmp_dir"
    
    # Make executable
    chmod +x "$CODEQL_HOME/codeql/codeql"
}

# Function to setup PATH
setup_path() {
    echo "🔧 Configuring PATH..."
    
    local shell_rc="$HOME/.zshrc"
    if [ ! -f "$shell_rc" ]; then
        shell_rc="$HOME/.bashrc"
    fi
    
    # Check if PATH is already configured
    if ! grep -q "CODEQL_HOME" "$shell_rc"; then
        cat >> "$shell_rc" << 'EOF'

# CodeQL Configuration
export CODEQL_HOME="$HOME/.codeql-home"
export PATH="$CODEQL_HOME/codeql:$PATH"
EOF
        print_success "Added CodeQL to PATH in $shell_rc"
    else
        print_info "PATH already configured in $shell_rc"
    fi
    
    # Export for current session
    export CODEQL_HOME="$HOME/.codeql-home"
    export PATH="$CODEQL_HOME/codeql:$PATH"
    echo ""
    
    # Store shell_rc for later use
    SHELL_RC="$shell_rc"
}

# Main installation flow
main() {
    create_codeql_folder
    detect_os
    fetch_release "$CODEQL_VERSION" "$BUNDLE"
    extract_release "$TMP_DIR" "$BUNDLE"
    setup_path
    
    # Verify installation
    echo "✅ Verifying installation..."
    local version_output=$("$CODEQL_HOME/codeql/codeql" version)
    print_success "CodeQL CLI installed successfully!"
    echo ""
    echo "$version_output"
    echo ""
    
    # Next steps
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 Installation Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Reload your shell: source $SHELL_RC"
    echo "  2. Verify: codeql --version"
    echo "  3. Install libraries: ./install-libraries.sh"
    echo ""
}

# Run main installation
main
