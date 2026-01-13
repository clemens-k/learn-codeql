#!/bin/bash
# Script to configure VS Code CodeQL extension

set -e

echo "🔧 VS Code CodeQL Extension Configuration"
echo "=========================================="
echo ""

# Configuration
CODEQL_HOME="$HOME/.codeql-home"
VSCODE_SETTINGS="$HOME/.vscode-server/data/Machine/settings.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Check prerequisites
if [ ! -f "$CODEQL_HOME/codeql/codeql" ]; then
    echo "❌ CodeQL CLI not found. Run ./install-codeql.sh first"
    exit 1
fi

print_success "Prerequisites found"
echo ""

# Create settings directory if needed
mkdir -p "$(dirname "$VSCODE_SETTINGS")"

# Check if settings file exists
if [ ! -f "$VSCODE_SETTINGS" ]; then
    echo "{}" > "$VSCODE_SETTINGS"
    print_info "Created new settings file"
fi

echo "📝 Configuring CodeQL extension settings..."
echo ""

# Use jq to update settings if available, otherwise manual
if command -v jq &> /dev/null; then
    # Update settings using jq
    TMP_FILE=$(mktemp)
    jq ". + {
        \"codeQL.cli.executablePath\": \"$CODEQL_HOME/codeql/codeql\",
        \"codeQL.runningQueries.numberOfThreads\": 0,
        \"codeQL.runningQueries.memory\": 8192
    }" "$VSCODE_SETTINGS" > "$TMP_FILE"
    mv "$TMP_FILE" "$VSCODE_SETTINGS"
    print_success "Settings updated using jq"
else
    # Manual configuration message
    print_info "jq not available. Manual configuration required."
    echo ""
    echo "Add these settings to VS Code (Ctrl+,):"
    echo ""
    cat << EOF
{
    "codeQL.cli.executablePath": "$CODEQL_HOME/codeql/codeql",
    "codeQL.runningQueries.numberOfThreads": 0,
    "codeQL.runningQueries.memory": 8192
}
EOF
    echo ""
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 VS Code Configuration Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Next steps:"
echo "  1. Restart VS Code / Reload Window"
echo "  2. Open Command Palette (Ctrl+Shift+P)"
echo "  3. Run: 'CodeQL: Check Installation'"
echo "  4. Should see: ✓ CLI found, ✓ Libraries found"
echo ""
