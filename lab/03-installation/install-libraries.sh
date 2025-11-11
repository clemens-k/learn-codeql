#!/bin/bash
# Script to install CodeQL standard libraries

set -e

echo "📚 CodeQL Libraries Installation Script"
echo "========================================"
echo ""

# Configuration
CODEQL_HOME="$HOME/.codeql-home"
REPO_DIR="$CODEQL_HOME/codeql-repo"

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

# Check if CodeQL CLI is installed
if [ ! -f "$CODEQL_HOME/codeql/codeql" ]; then
    print_error "CodeQL CLI not found!"
    echo "Please run ./install-codeql.sh first"
    exit 1
fi

print_success "CodeQL CLI found"
echo ""

# Check if repo already exists
if [ -d "$REPO_DIR" ]; then
    print_info "Libraries already exist at $REPO_DIR"
    read -p "Do you want to update them? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📥 Updating libraries..."
        cd "$REPO_DIR"
        git pull
        print_success "Libraries updated"
        exit 0
    else
        echo "Installation cancelled."
        exit 0
    fi
fi

# Clone the repository
echo "📥 Cloning CodeQL standard libraries..."
echo "Repository: https://github.com/github/codeql.git"
echo "This may take a few minutes..."
echo ""

git clone --depth 1 https://github.com/github/codeql.git "$REPO_DIR"

print_success "Libraries cloned to $REPO_DIR"
echo ""

# Show what was installed
echo "📦 Installed language packs:"
cd "$REPO_DIR"
for dir in */; do
    if [ -f "${dir}ql/lib/qlpack.yml" ] || [ -f "${dir}qlpack.yml" ]; then
        echo "  • ${dir%/}"
    fi
done
echo ""

# Verify key languages
echo "✅ Verifying key languages..."
REQUIRED_LANGS=("cpp" "rust" "python" "java" "javascript")
ALL_FOUND=true

for lang in "${REQUIRED_LANGS[@]}"; do
    if [ -d "$REPO_DIR/$lang" ]; then
        print_success "$lang library found"
    else
        print_error "$lang library not found"
        ALL_FOUND=false
    fi
done

echo ""

if [ "$ALL_FOUND" = true ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 Libraries Installation Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Configure VS Code: ./configure-vscode.sh"
    echo "  2. Test with C++: ./create-cpp-database.sh"
    echo "  3. Test with Rust: ./create-rust-database.sh"
    echo ""
else
    print_error "Some libraries are missing. Clone may be incomplete."
    exit 1
fi
