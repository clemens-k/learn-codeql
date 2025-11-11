#!/bin/bash
# Comprehensive verification script for CodeQL setup

# Don't exit on errors - we want to check everything
# set -e  # REMOVED: We want to continue even if some checks fail

CODEQL_HOME="$HOME/.codeql-home"
PASSED=0
FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     CodeQL Installation Verification Script           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

check_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Check 1: CodeQL CLI exists
echo "1️⃣  Checking CodeQL CLI..."
if [ -f "$CODEQL_HOME/codeql/codeql" ]; then
    check_pass "CodeQL CLI found at $CODEQL_HOME/codeql/codeql"
else
    check_fail "CodeQL CLI not found"
fi

# Check 2: CodeQL in PATH
echo ""
echo "2️⃣  Checking PATH configuration..."
if command -v codeql &> /dev/null; then
    VERSION=$(codeql version 2>&1 | head -n 1 || echo "Version check failed")
    check_pass "CodeQL accessible from PATH"
    check_info "Version: $VERSION"
else
    check_fail "CodeQL not in PATH"
    check_info "Run: source ~/.zshrc (or ~/.bashrc)"
fi

# Check 3: Standard libraries
echo ""
echo "3️⃣  Checking standard libraries..."
if [ -d "$CODEQL_HOME/codeql-repo" ]; then
    check_pass "Standard libraries found"
    
    # Check specific languages
    for lang in cpp rust python java javascript; do
        if [ -d "$CODEQL_HOME/codeql-repo/$lang" ]; then
            check_pass "  $lang library present"
        else
            check_fail "  $lang library missing"
        fi
    done
else
    check_fail "Standard libraries not found"
fi

# Check 4: Coding standards (MISRA & CERT)
echo ""
echo "3️⃣b Checking coding standards..."
if [ -d "$CODEQL_HOME/coding-standards" ]; then
    check_pass "Coding standards repository found"
    
    # Check MISRA and CERT
    if [ -d "$CODEQL_HOME/coding-standards/cpp/misra" ]; then
        check_pass "  MISRA C++ queries present"
    else
        check_fail "  MISRA C++ queries missing"
    fi
    
    if [ -d "$CODEQL_HOME/coding-standards/cpp/cert" ]; then
        check_pass "  CERT C++ queries present"
    else
        check_fail "  CERT C++ queries missing"
    fi
    
    # Check pack dependencies
    if [ -d "$HOME/.codeql/packages/codeql/cpp-all" ]; then
        check_pass "  Pack dependencies installed"
    else
        check_warn "  Pack dependencies not installed"
        check_info "  Run: cd coding-standards/cpp/misra/src && codeql pack install"
    fi
else
    check_fail "Coding standards not found"
    check_info "  Run ./install-libraries.sh to install"
fi

# Check 5: VS Code settings
echo ""
echo "4️⃣  Checking VS Code configuration..."
VSCODE_SETTINGS="$HOME/.vscode-server/data/Machine/settings.json"
if [ -f "$VSCODE_SETTINGS" ]; then
    check_pass "VS Code settings file found"
    
    if command -v jq &> /dev/null; then
        if jq -e '.["codeQL.cli.executablePath"]' "$VSCODE_SETTINGS" > /dev/null 2>&1; then
            check_pass "  CodeQL CLI path configured"
        else
            check_fail "  CodeQL CLI path not configured"
        fi
    else
        check_info "  Install jq for detailed settings check"
    fi
else
    check_fail "VS Code settings not found"
fi

# Check 6: Build tools
echo ""
echo "6️⃣  Checking build tools..."
if command -v cmake &> /dev/null; then
    check_pass "CMake installed"
else
    check_fail "CMake not found"
fi

if command -v ninja &> /dev/null; then
    check_pass "Ninja installed"
else
    check_fail "Ninja not found (optional)"
fi

if command -v cargo &> /dev/null; then
    check_pass "Cargo (Rust) installed"
else
    check_fail "Cargo not found"
fi

# Check 7: Try creating a minimal database (optional)
echo ""
echo "7️⃣  Testing database creation..."
if command -v codeql &> /dev/null && [ -d "test-cpp-project" ]; then
    check_info "Creating test database (this may take a moment)..."
    
    TMP_DB="/tmp/codeql-verify-db-$$"
    if codeql database create "$TMP_DB" \
        --language=cpp \
        --source-root=test-cpp-project \
        --command="cd test-cpp-project/build && ninja" \
        > /dev/null 2>&1; then
        check_pass "Successfully created test database"
        rm -rf "$TMP_DB"
    else
        check_fail "Database creation failed"
        check_info "This might be okay if project isn't built yet"
    fi
else
    check_info "Skipping database creation test"
fi

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Summary                             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}Passed: $PASSED${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! Your CodeQL setup is complete.${NC}"
    echo ""
    echo "Next steps:"
    echo "  • cd test-cpp-project && mkdir build && cd build && cmake .. -G Ninja && ninja"
    echo "  • cd ../.. && ./create-cpp-database.sh"
    echo "  • ./analyze-cpp-database.sh"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some checks failed. Review the output above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "  • Run ./install-codeql.sh"
    echo "  • Run ./install-libraries.sh"
    echo "  • Run ./configure-vscode.sh"
    echo "  • Reload shell: source ~/.zshrc"
    exit 1
fi
