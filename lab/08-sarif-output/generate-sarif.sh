#!/bin/bash
# generate-sarif.sh - Generate sample SARIF files from existing databases

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
SUITE="security-and-quality"
OUTPUT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --suite)
            SUITE="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Create results directory
mkdir -p results

# Find available database
CPP_DB="../05-cpp-cmake-setup/databases/test-cpp-db"
RUST_DB="../04-rust-setup/databases/test-rust-db"

if [ -d "$CPP_DB" ]; then
    DB="$CPP_DB"
    LANG="cpp"
    echo -e "${BLUE}Using C++ database: $DB${NC}"
elif [ -d "$RUST_DB" ]; then
    DB="$RUST_DB"
    LANG="rust"
    echo -e "${BLUE}Using Rust database: $DB${NC}"
else
    echo "❌ No database found. Please complete Lab 04 or Lab 05 first."
    exit 1
fi

# Determine output file
if [ -z "$OUTPUT" ]; then
    OUTPUT="results/${SUITE}-scan.sarif"
fi

echo -e "${CYAN}Generating SARIF output...${NC}"
echo "  Suite: $SUITE"
echo "  Output: $OUTPUT"
echo ""

# Map suite name to query pack
case $SUITE in
    security)
        QUERY_SUITE="codeql/${LANG}-queries:codeql-suites/${LANG}-security-and-quality.qls"
        ;;
    quality)
        QUERY_SUITE="codeql/${LANG}-queries:codeql-suites/${LANG}-code-scanning.qls"
        ;;
    extended|security-extended)
        QUERY_SUITE="codeql/${LANG}-queries:codeql-suites/${LANG}-security-extended.qls"
        ;;
    security-and-quality)
        QUERY_SUITE="codeql/${LANG}-queries:codeql-suites/${LANG}-security-and-quality.qls"
        ;;
    *)
        QUERY_SUITE="$SUITE"
        ;;
esac

# Run analysis
codeql database analyze "$DB" \
    "$QUERY_SUITE" \
    --format=sarif-latest \
    --output="$OUTPUT" \
    --sarif-add-baseline-file-info \
    --threads=0

echo ""
echo -e "${GREEN}✅ SARIF file generated: $OUTPUT${NC}"

# Show summary
TOTAL=$(jq '.runs[0].results | length' "$OUTPUT")
ERRORS=$(jq '[.runs[0].results[] | select(.level == "error")] | length' "$OUTPUT")
WARNINGS=$(jq '[.runs[0].results[] | select(.level == "warning")] | length' "$OUTPUT")

echo ""
echo "Summary:"
echo "  Total findings: $TOTAL"
echo "  Errors:         $ERRORS"
echo "  Warnings:       $WARNINGS"
echo ""
echo "View with: jq . $OUTPUT | less"
