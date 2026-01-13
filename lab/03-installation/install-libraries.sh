#!/bin/bash
# Script to install CodeQL coding standards from GitHub releases
# Usage: ./install-libraries.sh [version]
#   version: Optional. Specific version to install (e.g., v2.51.0)
#            If not provided, installs the latest version.
#
# Required packages: curl jq unzip tar sha256sum

set -e

SCRIPT_NAME=$(basename "$0")

# Parse command-line arguments
CODING_STANDARDS_VERSION="${1:-latest}"

echo "📚 CodeQL Coding Standards Installation Script"
echo "=============================================="
echo ""
echo "Version: $CODING_STANDARDS_VERSION"
echo ""

# Configuration
CODEQL_HOME="$HOME/.codeql-home"
CODING_STANDARDS_DIR="$CODEQL_HOME/codeql-coding-standards"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check prerequisites
if [ ! -f "$CODEQL_HOME/codeql/codeql" ]; then
    print_error "CodeQL CLI not found!"
    echo "Please run ./install-codeql.sh first"
    exit 1
fi

print_success "CodeQL CLI found"
echo ""

# ========================================
# Determine version to install
# ========================================

if [ "$CODING_STANDARDS_VERSION" = "latest" ]; then
    echo "🔍 Fetching latest release version..."
    CODING_STANDARDS_VERSION=$(curl -s https://api.github.com/repos/github/codeql-coding-standards/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$CODING_STANDARDS_VERSION" ]; then
        print_error "Failed to fetch latest version"
        echo "Please specify a version manually, e.g., ./install-libraries.sh v2.51.0"
        exit 1
    fi
    
    echo -e "${CYAN}Latest version: ${CODING_STANDARDS_VERSION}${NC}"
    echo ""
fi

# ========================================
# Install Coding Standards (MISRA & CERT)
# ========================================

echo "📥 Installing CodeQL Coding Standards (MISRA & CERT)..."
echo ""

# Check if coding standards already exist
if [ -d "$CODING_STANDARDS_DIR" ]; then
    print_info "Coding standards already exist at $CODING_STANDARDS_DIR"
    read -p "Do you want to reinstall them? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "�️  Removing existing installation..."
        rm -rf "$CODING_STANDARDS_DIR"
    else
        print_info "Skipping coding standards installation"
        SKIP_CODING_STANDARDS=true
    fi
fi

if [ "$SKIP_CODING_STANDARDS" != "true" ]; then
    # Download pre-built coding standards assets from GitHub releases
    echo "📦 Downloading coding standards release assets..."
    echo -e "${CYAN}Version: ${CODING_STANDARDS_VERSION}${NC}"
    echo "Repository: https://github.com/github/codeql-coding-standards"
    echo ""
    echo "💡 Downloading all release assets including:"
    echo "   • Code scanning query pack (C/C++ coding standards)"
    echo "   • Documentation and certification materials"
    echo "   • Checksums for verification"
    echo ""

    # Create temporary directory
    TMP_DIR=$(mktemp -d --tmpdir "$SCRIPT_NAME.XXX")
    print_info "Using temporary directory: $TMP_DIR"

    # Determine API URL based on version
    if [ "$CODING_STANDARDS_VERSION" = "latest" ]; then
        API_URL="https://api.github.com/repos/github/codeql-coding-standards/releases/latest"
    else
        API_URL="https://api.github.com/repos/github/codeql-coding-standards/releases/tags/${CODING_STANDARDS_VERSION}"
    fi

    # Fetch release information
    echo "🔍 Fetching release information from GitHub API..."
    RELEASE_JSON=$(curl -s "$API_URL")
    
    if [ -z "$RELEASE_JSON" ] || echo "$RELEASE_JSON" | grep -q '"message": "Not Found"'; then
        print_error "Failed to fetch release information"
        echo "Version ${CODING_STANDARDS_VERSION} not found"
        exit 1
    fi

    # Extract all asset download URLs and names using jq
    ASSET_COUNT=$(echo "$RELEASE_JSON" | jq '.assets | length')
    echo -e "${CYAN}Found ${ASSET_COUNT} assets to download${NC}"
    echo ""
    
    mkdir -p "$CODING_STANDARDS_DIR"
    cd "$TMP_DIR"
    
    # Download each asset
    echo "📥 Downloading assets..."
    for i in $(seq 0 $((ASSET_COUNT - 1))); do
        ASSET_NAME=$(echo "$RELEASE_JSON" | jq -r ".assets[$i].name")
        ASSET_URL=$(echo "$RELEASE_JSON" | jq -r ".assets[$i].browser_download_url")
        
        echo "  Downloading ${ASSET_NAME} ..."
        curl -L -o "$ASSET_NAME" "$ASSET_URL"
        echo ""
    done
    
    echo ""
    
    # Verify checksums if checksums.txt exists
    if [ -f "checksums.txt" ]; then
        echo "🔐 Verifying checksums..."
        
        if sha256sum -c checksums.txt 2>/dev/null; then
            print_success "All checksums verified"
        else
            print_error "Checksum verification failed!"
            echo "Downloaded files may be corrupted"
            exit 1
        fi
        echo ""
    else
        print_warning "No checksums.txt found - skipping verification"
        echo ""
    fi
    
    # Extract code-scanning query pack (supports both old and new releases)
    echo "📦 Extracting CodeQL packs..."
    
    # Look for code-scanning-*-query-pack.zip (works for old and new releases)
    QUERY_PACK_ZIP=$(find . -maxdepth 1 -name "*-query-pack.zip" | head -1)
    
    if [ -n "$QUERY_PACK_ZIP" ] && [ -f "$QUERY_PACK_ZIP" ]; then
        PACK_NAME=$(basename "$QUERY_PACK_ZIP")
        echo "  Found query pack: ${PACK_NAME}"
        echo "  Extracting directly to ${CODEQL_HOME}..."
        
        # Extract directly to CODEQL_HOME
        unzip -q "$QUERY_PACK_ZIP" -d "$CODEQL_HOME"
        print_success "  Query pack extracted"

        # some idiot at codeql decided to store a zip inside a zip archive
        unzip -q "${CODEQL_HOME}/code-scanning-cpp-query-pack.zip" -d "$CODEQL_HOME"
        
        # Verify the coding-standards were extracted by looking for qlpack.yml files
        EXTRACTED_PACKS=$(find "$CODING_STANDARDS_DIR" -name "qlpack.yml" 2>/dev/null | wc -l)
            
        if [ "$EXTRACTED_PACKS" -gt 0 ]; then
            print_success "  Found ${EXTRACTED_PACKS} coding standards pack(s)"
            rm "${CODEQL_HOME}/code-scanning-cpp-query-pack.zip" 2>/dev/null || truey
        else
            print_error "  No coding standards packs found after extraction!"
            echo "  Expected to find directories matching codeql-coding-standards-* with qlpack.yml"
            exit 1
        fi

        # Verify that the codeql cli version matches the expected version
        if [ -f "$CODING_STANDARDS_DIR/supported_codeql_configs.json" ]; then
            echo ""
            echo "🔍 Checking CodeQL CLI version compatibility..."
            
            # Get installed CLI version
            INSTALLED_CLI_VERSION=$("$CODEQL_HOME/codeql/codeql" version --format=text 2>/dev/null | head -1 | sed -E 's/.*release ([0-9.]+)\..*/\1/')
            
            # Get expected CLI version from supported_codeql_configs.json
            EXPECTED_CLI_VERSION=$(jq -r '.supported_environment[0].codeql_cli' "$CODING_STANDARDS_DIR/supported_codeql_configs.json")
            
            if [ -n "$EXPECTED_CLI_VERSION" ] && [ -n "$INSTALLED_CLI_VERSION" ]; then
                echo "  Installed CLI: ${INSTALLED_CLI_VERSION}"
                echo "  Expected CLI:  ${EXPECTED_CLI_VERSION}"
                
                if [ "$INSTALLED_CLI_VERSION" = "$EXPECTED_CLI_VERSION" ]; then
                    print_success "CLI versions match"
                else
                    print_warning "CLI version mismatch detected!"
                    echo ""
                    echo -e "${YELLOW}  The coding standards were built with CodeQL CLI ${EXPECTED_CLI_VERSION}${NC}"
                    echo -e "${YELLOW}  but you have ${INSTALLED_CLI_VERSION} installed.${NC}"
                    echo ""
                    echo -e "${YELLOW}  This may cause compatibility issues.${NC}"
                    echo -e "${YELLOW}  Consider installing the matching CLI version:${NC}"
                    echo -e "${YELLOW}    ./install-codeql.sh v${EXPECTED_CLI_VERSION}${NC}"
                fi
            else
                print_info "Could not determine CLI versions for comparison"
            fi
        else
            print_warning "No supported_codeql_configs.json found for version check"
        fi
    else
        print_warning "No code-scanning query pack found in this release!"
        echo ""
        echo "Available assets:"
        ls -1 *.zip 2>/dev/null || echo "  (no zip files)"
        echo ""
        echo "This release may not include C/C++ coding standards."
        echo "Please check the release notes or try a different version."
        exit 1
    fi
    
    echo ""
    
    # Copy documentation and metadata to the destination
    echo "📄 Copying documentation and metadata..."
    for file in *.txt *.csv *.md; do
        if [ -f "$file" ]; then
            cp "$file" "$CODING_STANDARDS_DIR/" 2>/dev/null || true
        fi
    done
    print_success "Documentation copied"
    
    echo ""
    print_success "All assets processed and installed to $CODING_STANDARDS_DIR"
    echo ""
    echo -e "${CYAN}📝 Note: CodeQL packs include precompiled .qlx files${NC}"
    echo -e "${CYAN}   When using these, add --expect-discarded-cache to analyze commands${NC}"
fi
echo ""


# ========================================
# Verify Installation
# ========================================

echo "✅ Verifying coding standards installation..."
ALL_FOUND=true

if [ "$SKIP_CODING_STANDARDS" = "true" ]; then
    print_info "Coding standards installation skipped"
elif [ -d "$CODING_STANDARDS_DIR" ] && [ -n "$(ls -A "$CODING_STANDARDS_DIR" 2>/dev/null)" ]; then
    PACK_COUNT=$(find "$CODING_STANDARDS_DIR" -name "qlpack.yml" | wc -l)
    
    if [ "$PACK_COUNT" -eq 0 ]; then
        print_error "No CodeQL packs found (0 qlpack.yml files)!"
        print_error "The extraction may have failed"
        ALL_FOUND=false
    else
        print_success "Coding standards found (${PACK_COUNT} packs installed)"
        echo "  Installed packs:"
        for PACK_DIR in "$CODING_STANDARDS_DIR"/*; do
            if [ -d "$PACK_DIR" ] && [ -f "$PACK_DIR/qlpack.yml" ]; then
                PACK_NAME=$(basename "$PACK_DIR")
                echo "    • ${PACK_NAME}"
            fi
        done
    fi
else
    print_error "Coding standards not properly installed"
    ALL_FOUND=false
fi

echo ""

if [ "$ALL_FOUND" = true ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 Coding Standards Installation Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📝 What was installed:"
    echo "  • Pre-built coding standards packs (${CODING_STANDARDS_VERSION})"
    echo "  • All pack dependencies"
    echo "  • Documentation and checksums"
    echo ""
    echo "💡 Benefits of pre-built packs:"
    echo "  • Faster download (no large git history)"
    echo "  • Includes precompiled .qlx files"
    echo "  • Ready to use with --expect-discarded-cache"
    echo "  • Verified with checksums"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Configure VS Code: ./configure-vscode.sh"
    echo "  2. Test with C++: ./create-cpp-database.sh"
    echo "  3. Test with Rust: ./create-rust-database.sh"
    echo ""
    echo "🔄 To use a different version:"
    echo "  ./install-libraries.sh v2.50.0"
    echo ""
else
    print_error "Coding standards installation incomplete."
    echo ""
    echo "Please check:"
    echo "  • The version ${CODING_STANDARDS_VERSION} exists"
    echo "  • You have sufficient disk space"
    echo "  • Network connection is stable"
    exit 1
fi
