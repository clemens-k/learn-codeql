#!/bin/bash
# run-all-suites.sh - Run all query suites on test projects

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPP_DB="../05-cpp-cmake-setup/databases/test-cpp-db"
RUST_DB="../04-rust-setup/databases/test-rust-db"
RESULTS_DIR="$SCRIPT_DIR/results"

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}🔍 Running all query suites...${NC}\n"

# Function to run a suite
run_suite() {
    local db=$1
    local lang=$2
    local suite_name=$3
    local suite_path=$4
    local output=$5
    
    echo -e "${YELLOW}Running $suite_name suite for $lang...${NC}"
    
    if codeql database analyze "$db" \
        "$suite_path" \
        --format=sarif-latest \
        --output="$output" \
        --threads=0 \
        2>&1 | grep -v "^$"; then
        
        local count=$(jq '.runs[0].results | length' "$output")
        echo -e "${GREEN}✓ Complete: $count findings${NC}\n"
    else
        echo -e "${RED}✗ Failed${NC}\n"
        return 1
    fi
}

# Check if databases exist
if [ ! -d "$CPP_DB" ] && [ ! -d "$RUST_DB" ]; then
    echo -e "${RED}Error: No databases found!${NC}"
    echo "Please run Lab 04 or Lab 05 first to create databases."
    exit 1
fi

# C++ Analysis
if [ -d "$CPP_DB" ]; then
    echo -e "${BLUE}=== C++ Analysis ===${NC}\n"
    
    echo -e "${YELLOW}[1/3] Code Scanning Suite (Fast, Production)${NC}"
    run_suite "$CPP_DB" "C++" "code-scanning" \
        "codeql/cpp-queries:codeql-suites/cpp-code-scanning.qls" \
        "$RESULTS_DIR/cpp-code-scanning.sarif"
    
    echo -e "${YELLOW}[2/3] Security and Quality Suite (Balanced)${NC}"
    run_suite "$CPP_DB" "C++" "security-and-quality" \
        "codeql/cpp-queries:codeql-suites/cpp-security-and-quality.qls" \
        "$RESULTS_DIR/cpp-security-and-quality.sarif"
    
    echo -e "${YELLOW}[3/3] Security Extended Suite (Comprehensive)${NC}"
    run_suite "$CPP_DB" "C++" "security-extended" \
        "codeql/cpp-queries:codeql-suites/cpp-security-extended.qls" \
        "$RESULTS_DIR/cpp-security-extended.sarif"
fi

# Rust Analysis
if [ -d "$RUST_DB" ]; then
    echo -e "${BLUE}=== Rust Analysis ===${NC}\n"
    
    echo -e "${YELLOW}[1/3] Code Scanning Suite (Fast, Production)${NC}"
    run_suite "$RUST_DB" "Rust" "code-scanning" \
        "codeql/rust-queries:codeql-suites/rust-code-scanning.qls" \
        "$RESULTS_DIR/rust-code-scanning.sarif"
    
    echo -e "${YELLOW}[2/3] Security and Quality Suite (Balanced)${NC}"
    run_suite "$RUST_DB" "Rust" "security-and-quality" \
        "codeql/rust-queries:codeql-suites/rust-security-and-quality.qls" \
        "$RESULTS_DIR/rust-security-and-quality.sarif"
    
    echo -e "${YELLOW}[3/3] Security Extended Suite (Comprehensive)${NC}"
    run_suite "$RUST_DB" "Rust" "security-extended" \
        "codeql/rust-queries:codeql-suites/rust-security-extended.qls" \
        "$RESULTS_DIR/rust-security-extended.sarif"
fi

echo -e "${GREEN}✓ All suites complete!${NC}\n"
echo -e "${BLUE}📊 Results saved to: $RESULTS_DIR/${NC}"
echo ""
echo "Quick summary:"
for file in "$RESULTS_DIR"/*.sarif; do
    if [ -f "$file" ]; then
        count=$(jq '.runs[0].results | length' "$file")
        echo "  $(basename "$file"): $count findings"
    fi
done

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  - Run ./compare-suites.sh to compare results"
echo "  - Run ./analyze-by-severity.sh <file> to analyze findings"
echo "  - Run ./filter-results.sh <file> to filter results"
