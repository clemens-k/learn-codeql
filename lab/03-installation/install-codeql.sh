#!/bin/bash
# Script to install CodeQL CLI

set -e

echo "🚀 CodeQL CLI Installation Script"
echo "=================================="
echo ""

# Configuration
CODEQL_HOME="$HOME/.codeql-home"
CODEQL_VERSION="latest"

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

# Check if already installed
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

# Create directory
echo "📁 Creating CodeQL home directory..."
mkdir -p "$CODEQL_HOME"
print_success "Directory created: $CODEQL_HOME"
echo ""

# Detect OS and architecture
echo "🔍 Detecting operating system..."
OS=$(uname -s)

case "$OS" in
    Linux*)
        BUNDLE="codeql-linux64.zip"
        ;;
    Darwin*)
        BUNDLE="codeql-osx64.zip"
        ;;
    *)
        print_error "Unsupported OS: $OS"
        exit 1
        ;;
esac

print_success "Detected: $OS ($ARCH)"
print_info "Bundle: $BUNDLE"
echo ""

# Get latest release URL
echo "🌐 Fetching latest CodeQL release..."
RELEASE_URL="https://api.github.com/repos/github/codeql-cli-binaries/releases/latest"
DOWNLOAD_URL=$(curl -s "$RELEASE_URL" | grep "browser_download_url.*$BUNDLE\"" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    print_error "Failed to find download URL for $BUNDLE"
    exit 1
fi

print_success "Found latest release"
print_info "URL: $DOWNLOAD_URL"
echo ""

# Download CodeQL
echo "⬇️  Downloading CodeQL CLI..."
TMP_FILE="/tmp/codeql.zip"
curl -L -o "$TMP_FILE" "$DOWNLOAD_URL"
print_success "Downloaded to $TMP_FILE"
echo ""

# Extract
echo "📦 Extracting CodeQL CLI..."
cd "$CODEQL_HOME"
unzip "$TMP_FILE"
rm "$TMP_FILE"
print_success "Extracted to $CODEQL_HOME/codeql"
echo ""

# Make executable
chmod +x "$CODEQL_HOME/codeql/codeql"

# Update PATH
echo "🔧 Configuring PATH..."
SHELL_RC="$HOME/.zshrc"
if [ ! -f "$SHELL_RC" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

# Check if PATH is already configured
if ! grep -q "CODEQL_HOME" "$SHELL_RC"; then
    cat >> "$SHELL_RC" << 'EOF'

# CodeQL Configuration
export CODEQL_HOME="$HOME/.codeql-home"
export PATH="$CODEQL_HOME/codeql:$PATH"
EOF
    print_success "Added CodeQL to PATH in $SHELL_RC"
else
    print_info "PATH already configured in $SHELL_RC"
fi

# Export for current session
export CODEQL_HOME="$HOME/.codeql-home"
export PATH="$CODEQL_HOME/codeql:$PATH"
echo ""

# Verify installation
echo "✅ Verifying installation..."
VERSION_OUTPUT=$("$CODEQL_HOME/codeql/codeql" version)
print_success "CodeQL CLI installed successfully!"
echo ""
echo "$VERSION_OUTPUT"
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
