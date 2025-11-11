#!/bin/bash
# run-cert-checks.sh - Run CERT C/C++ compliance checks

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

mkdir -p "$RESULTS_DIR"

echo -e "${BLUE}🔒 Running CERT C/C++ Secure Coding Checks...${NC}\n"

# Check if database exists
if [ ! -d "$CPP_DB" ]; then
    echo -e "${RED}Error: C++ database not found!${NC}"
    echo "Please run Lab 05 first:"
    echo "  cd ../05-cpp-cmake-setup && ./create-cpp-database.sh"
    exit 1
fi

# Run CERT compliance check
echo "Analyzing: $CPP_DB"
echo "Query suite: Using CodeQL cpp-queries with CERT tags"
echo ""

if codeql database analyze "$CPP_DB" \
    codeql/cpp-queries \
    --format=sarif-latest \
    --output="$RESULTS_DIR/cert-results.sarif" \
    --threads=0 \
    2>&1 | grep -v "^$"; then
    
    echo -e "\n${GREEN}✓ Analysis complete${NC}\n"
else
    echo -e "\n${RED}✗ Analysis failed${NC}\n"
    exit 1
fi

# Filter to CERT-tagged results only
echo "Filtering CERT-specific results..."
jq '.runs[0].results |= 
    map(select(.rule.properties.tags | 
    any(startswith("external/cert"))))' \
    "$RESULTS_DIR/cert-results.sarif" \
    > "$RESULTS_DIR/cert-filtered.sarif"

mv "$RESULTS_DIR/cert-filtered.sarif" "$RESULTS_DIR/cert-results.sarif"

# Generate summary
TOTAL=$(jq '.runs[0].results | length' "$RESULTS_DIR/cert-results.sarif")

echo -e "${BLUE}📊 CERT Compliance Summary:${NC}"
echo "  Total violations: $TOTAL"
echo ""

# Count by category
echo "  By category:"
jq -r '.runs[0].results | 
    map(.ruleId | match("cert/([a-z]+)[0-9]+-") | 
    .captures[0].string) | 
    group_by(.) | 
    map("    \(.[0] | ascii_upcase): \(length) violations") | 
    sort | 
    .[]' \
    "$RESULTS_DIR/cert-results.sarif" 2>/dev/null || echo "    (no categories found)"

echo ""

# Show critical issues
CRITICAL=$(jq '[.runs[0].results[] | 
    select(.level == "error")] | length' \
    "$RESULTS_DIR/cert-results.sarif")

if [ "$CRITICAL" -gt 0 ]; then
    echo -e "${RED}⚠️  $CRITICAL critical violations found!${NC}"
    echo ""
    echo "Top critical violations:"
    jq -r '.runs[0].results[] | 
        select(.level == "error") | 
        "\(.ruleId): \(.message.text[:60])..."' \
        "$RESULTS_DIR/cert-results.sarif" | head -5
else
    echo -e "${GREEN}✓ No critical violations${NC}"
fi

echo ""
echo -e "${BLUE}Results saved to:${NC} $RESULTS_DIR/cert-results.sarif"
echo ""
echo "Next steps:"
echo "  • Filter by category: jq '.runs[0].results |= map(select(.ruleId | test(\"cert/mem\")))' results/cert-results.sarif"
echo "  • Generate report: ./generate-report.sh results/"
echo "  • View in VS Code: code results/cert-results.sarif"
