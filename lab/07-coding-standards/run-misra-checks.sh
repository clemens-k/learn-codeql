#!/bin/bash
# run-misra-checks.sh - Run MISRA C++:2023 compliance checks

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPP_DB="../05-cpp-cmake-setup/databases/test-cpp-db"
RESULTS_DIR="$SCRIPT_DIR/results"
CODING_STANDARDS="$HOME/.codeql-home/coding-standards"

mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}🔍 Running MISRA C++:2023 Compliance Checks...${NC}\n"

# Check if database exists
if [ ! -d "$CPP_DB" ]; then
    echo -e "${RED}Error: C++ database not found!${NC}"
    echo "Please run Lab 05 first:"
    echo "  cd ../05-cpp-cmake-setup && ./create-cpp-database.sh"
    exit 1
fi

# Check if coding standards are installed
if [ ! -d "$CODING_STANDARDS/cpp/misra" ]; then
    echo -e "${RED}Error: CodeQL coding standards not found!${NC}"
    echo "Please run Lab 03 to install coding standards:"
    echo "  cd ../03-installation && ./install-libraries.sh"
    exit 1
fi

# Run MISRA C++:2023 compliance check
echo "Analyzing: $CPP_DB"
echo "Query pack: $CODING_STANDARDS/cpp/misra/src"
echo ""

# Find available query suite or use the query pack directly
if [ -f "$CODING_STANDARDS/cpp/misra/src/codeql-suites/misra-cpp-2023.qls" ]; then
    QUERY_PATH="$CODING_STANDARDS/cpp/misra/src/codeql-suites/misra-cpp-2023.qls"
else
    # Use the entire misra query pack
    QUERY_PATH="$CODING_STANDARDS/cpp/misra/src"
fi

if codeql database analyze "$CPP_DB" \
    "$QUERY_PATH" \
    --format=sarif-latest \
    --output="$RESULTS_DIR/misra-results.sarif" \
    --search-path="$CODING_STANDARDS" \
    --threads=0 \
    2>&1 | grep -v "^$"; then
    
    echo -e "\n${GREEN}✓ Analysis complete${NC}\n"
else
    echo -e "\n${RED}✗ Analysis failed${NC}\n"
    echo "Note: Some MISRA queries may require specific CodeQL version or configuration"
    exit 1
fi

# Generate summary
TOTAL=$(jq '.runs[0].results | length' "$RESULTS_DIR/misra-results.sarif")
REQUIRED=$(jq '[.runs[0].results[] | 
    select(.rule.properties.tags | 
    contains(["external/misra/obligation/required"]))] | length' \
    "$RESULTS_DIR/misra-results.sarif")
ADVISORY=$(jq '[.runs[0].results[] | 
    select(.rule.properties.tags | 
    contains(["external/misra/obligation/advisory"]))] | length' \
    "$RESULTS_DIR/misra-results.sarif")

echo -e "${BLUE}📊 MISRA Compliance Summary:${NC}"
echo "  Total violations: $TOTAL"
echo "  Required rules:   $REQUIRED violations"
echo "  Advisory rules:   $ADVISORY violations"
echo ""

if [ "$REQUIRED" -gt 0 ]; then
    echo -e "${RED}⚠️  High-priority violations found!${NC}"
    echo ""
    echo "Top required rule violations:"
    jq -r '.runs[0].results[] | 
        select(.rule.properties.tags | 
        contains(["external/misra/obligation/required"])) | 
        "\(.ruleId): \(.message.text[:60])..."' \
        "$RESULTS_DIR/misra-results.sarif" | head -5
else
    echo -e "${GREEN}✓ No required rule violations${NC}"
fi

echo ""
echo -e "${BLUE}Results saved to:${NC} $RESULTS_DIR/misra-results.sarif"
echo ""
echo "Next steps:"
echo "  • Filter by obligation: ./filter-by-obligation.sh results/misra-results.sarif required"
echo "  • Generate report: ./generate-report.sh results/"
echo "  • View in VS Code: code results/misra-results.sarif"
