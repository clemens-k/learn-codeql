#!/bin/bash
# compile-queries.sh - Pre-compile CodeQL queries to warm up the cache
# This speeds up subsequent analyses by avoiding compilation during analysis
#
# Note: The compilation cache uses a global lock, so we compile suites
# sequentially rather than individual queries in parallel.

# Don't exit on error - we want to try all suites even if some fail
set +e

# Configuration
CODEQL_HOME="$HOME/.codeql-home"
CODEQL_REPO="$CODEQL_HOME/codeql-repo"
CODING_STANDARDS="$CODEQL_HOME/coding-standards"
COMPILE_CACHE="$HOME/.codeql/compile-cache"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     CodeQL Query Compilation Cache Warmer             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}This script pre-compiles CodeQL queries to speed up future analyses.${NC}"
echo -e "${CYAN}First-time compilation might take > 30min but subsequent runs will be instant!${NC}"
echo ""
echo -e "${YELLOW}Note: The compilation cache uses a global lock, so compilation${NC}"
echo -e "${YELLOW}      must be done sequentially (not in parallel).${NC}"
echo ""

# Check prerequisites
if [ ! -f "$CODEQL_HOME/codeql/codeql" ]; then
    echo -e "${RED}Error: CodeQL CLI not found!${NC}"
    echo "Please run ./install-codeql.sh first"
    exit 1
fi

if [ ! -d "$CODEQL_REPO" ]; then
    echo -e "${RED}Error: CodeQL repository not found!${NC}"
    echo "Please run ./install-libraries.sh first"
    exit 1
fi

START_TIME=$(date +%s)
TOTAL_COMPILED=0
TOTAL_FAILED=0

# Function to compile a query suite
compile_suite() {
    local suite_path="$1"
    local description="$2"
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}${description}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ ! -f "$suite_path" ] && [ ! -d "$suite_path" ]; then
        echo -e "${YELLOW}⚠ Skipping: Not found${NC}"
        return
    fi
    
    echo -e "Compiling: ${suite_path/$HOME/~}"
    echo ""
    
    # Compile and capture exit code
    if codeql query compile "$suite_path" --threads=1 2>&1; then
        local exit_code=$?
    else
        local exit_code=$?
    fi
    
    echo ""
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ Compilation successful${NC}"
        ((TOTAL_COMPILED++))
    else
        echo -e "${RED}✗ Compilation failed (exit code: $exit_code)${NC}"
        ((TOTAL_FAILED++))
    fi
}

# Main compilation process

# 1. C++ security and quality queries
compile_suite \
    "$CODEQL_REPO/cpp/ql/src/codeql-suites/cpp-code-scanning.qls" \
    "Compiling C++ Code Scanning Queries"

compile_suite \
    "$CODEQL_REPO/cpp/ql/src/codeql-suites/cpp-security-extended.qls" \
    "Compiling C++ Security Extended Queries"

compile_suite \
    "$CODEQL_REPO/cpp/ql/src/codeql-suites/cpp-security-and-quality.qls" \
    "Compiling C++ Security and Quality Queries"

# 2. Rust queries
compile_suite \
    "$CODEQL_REPO/rust/ql/src/codeql-suites/rust-code-scanning.qls" \
    "Compiling Rust Code Scanning Queries"

compile_suite \
    "$CODEQL_REPO/rust/ql/src/codeql-suites/rust-security-extended.qls" \
    "Compiling Rust Security Extended Queries"

compile_suite \
    "$CODEQL_REPO/rust/ql/src/codeql-suites/rust-security-and-quality.qls" \
    "Compiling Rust Security and Quality Queries"

# 3. MISRA C++ (if available)
if [ -d "$CODING_STANDARDS/cpp/misra" ]; then
    # Try suite file first, then directory
    if [ -f "$CODING_STANDARDS/cpp/misra/src/codeql-suites/misra-cpp-2023.qls" ]; then
        compile_suite \
            "$CODING_STANDARDS/cpp/misra/src/codeql-suites/misra-cpp-2023.qls" \
            "Compiling MISRA C++:2023 Queries"
    elif [ -d "$CODING_STANDARDS/cpp/misra/src" ]; then
        compile_suite \
            "$CODING_STANDARDS/cpp/misra/src" \
            "Compiling MISRA C++ Queries"
    fi
fi

# 4. MISRA C (if available)
if [ -d "$CODING_STANDARDS/c/misra" ]; then
    if [ -f "$CODING_STANDARDS/c/misra/src/codeql-suites/misra-c-2012.qls" ]; then
        compile_suite \
            "$CODING_STANDARDS/c/misra/src/codeql-suites/misra-c-2012.qls" \
            "Compiling MISRA C:2012 Queries"
    elif [ -d "$CODING_STANDARDS/c/misra/src" ]; then
        compile_suite \
            "$CODING_STANDARDS/c/misra/src" \
            "Compiling MISRA C Queries"
    fi
fi

# 5. CERT C++ (if available)
if [ -d "$CODING_STANDARDS/cpp/cert" ]; then
    if [ -f "$CODING_STANDARDS/cpp/cert/src/codeql-suites/cert-cpp.qls" ]; then
        compile_suite \
            "$CODING_STANDARDS/cpp/cert/src/codeql-suites/cert-cpp.qls" \
            "Compiling CERT C++ Queries"
    elif [ -d "$CODING_STANDARDS/cpp/cert/src" ]; then
        compile_suite \
            "$CODING_STANDARDS/cpp/cert/src" \
            "Compiling CERT C++ Queries"
    fi
fi

# 6. CERT C (if available)
if [ -d "$CODING_STANDARDS/c/cert" ]; then
    if [ -f "$CODING_STANDARDS/c/cert/src/codeql-suites/cert-c.qls" ]; then
        compile_suite \
            "$CODING_STANDARDS/c/cert/src/codeql-suites/cert-c.qls" \
            "Compiling CERT C Queries"
    elif [ -d "$CODING_STANDARDS/c/cert/src" ]; then
        compile_suite \
            "$CODING_STANDARDS/c/cert/src" \
            "Compiling CERT C Queries"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Summary                             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}Successfully compiled: ${TOTAL_COMPILED} suites${NC}"
echo -e "  ${RED}Failed:                ${TOTAL_FAILED} suites${NC}"
echo ""
echo -e "  Time taken: ${YELLOW}${MINUTES}m ${SECONDS}s${NC}"
echo ""

# Show cache size
if [ -d "$COMPILE_CACHE" ]; then
    CACHE_SIZE=$(du -sh "$COMPILE_CACHE" 2>/dev/null | cut -f1 || echo "unknown")
    echo -e "  Compilation cache size: ${CYAN}${CACHE_SIZE}${NC}"
    echo -e "  Cache location: ${COMPILE_CACHE}"
    echo ""
fi

if [ "$TOTAL_COMPILED" -gt 0 ]; then
    echo -e "${GREEN}🎉 Query cache warmed successfully!${NC}"
    echo ""
    echo -e "${CYAN}Benefits:${NC}"
    echo -e "  • Future analyses will start faster (skip compilation)"
    echo -e "  • Especially noticeable for complex queries (data flow, taint tracking)"
    echo -e "  • Cache is shared across all databases"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  • Run analyses - they should be much faster now!"
    echo -e "  • cd ../05-cpp-cmake-setup && ./analyze-cpp-database.sh"
    echo -e "  • cd ../04-rust-setup && ./analyze-rust-database.sh"
    echo ""
else
    echo -e "${RED}⚠ No query suites were compiled successfully${NC}"
    echo ""
    echo "Please check:"
    echo "  • CodeQL CLI is properly installed"
    echo "  • Query libraries are present"
    echo "  • You have sufficient disk space"
    exit 1
fi
