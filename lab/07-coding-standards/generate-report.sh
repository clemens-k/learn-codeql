#!/bin/bash
# generate-report.sh - Generate compliance reports

set -e

# Colors
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo "Usage: $0 <results-directory>"
    echo ""
    echo "Example:"
    echo "  $0 results/"
    exit 1
fi

RESULTS_DIR=$1
REPORT_FILE="$RESULTS_DIR/compliance-report.txt"

echo -e "${BLUE}📊 Generating Coding Standards Compliance Report...${NC}\n"

{
    echo "================================================"
    echo "Coding Standards Compliance Report"
    echo "================================================"
    echo "Generated: $(date)"
    echo ""
    
    # MISRA Report
    if [ -f "$RESULTS_DIR/misra-results.sarif" ]; then
        echo "MISRA C++:2008 Compliance"
        echo "--------------------------"
        
        TOTAL=$(jq '.runs[0].results | length' "$RESULTS_DIR/misra-results.sarif")
        REQUIRED=$(jq '[.runs[0].results[] | 
            select(.rule.properties.tags | 
            contains(["external/misra/obligation/required"]))] | length' \
            "$RESULTS_DIR/misra-results.sarif")
        ADVISORY=$(jq '[.runs[0].results[] | 
            select(.rule.properties.tags | 
            contains(["external/misra/obligation/advisory"]))] | length' \
            "$RESULTS_DIR/misra-results.sarif")
        
        echo "Total Violations: $TOTAL"
        echo "  Required:       $REQUIRED (Priority: CRITICAL)"
        echo "  Advisory:       $ADVISORY (Priority: Review)"
        echo ""
        
        echo "Top Violations:"
        jq -r '.runs[0].results | 
            group_by(.ruleId) | 
            map({rule: .[0].ruleId, count: length}) | 
            sort_by(-.count) | 
            limit(5; .[]) | 
            "  \(.count)x \(.rule)"' \
            "$RESULTS_DIR/misra-results.sarif"
        echo ""
    fi
    
    # CERT Report
    if [ -f "$RESULTS_DIR/cert-results.sarif" ]; then
        echo "CERT C/C++ Compliance"
        echo "---------------------"
        
        TOTAL=$(jq '.runs[0].results | length' "$RESULTS_DIR/cert-results.sarif")
        echo "Total Violations: $TOTAL"
        echo ""
        
        echo "By Category:"
        jq -r '.runs[0].results | 
            map(.ruleId | match("cert/([a-z]+)[0-9]+-") | 
            .captures[0].string) | 
            group_by(.) | 
            map("  \(.[0] | ascii_upcase): \(length) violations") | 
            sort | 
            .[]' \
            "$RESULTS_DIR/cert-results.sarif" 2>/dev/null
        echo ""
        
        echo "Critical Issues:"
        jq -r '.runs[0].results[] | 
            select(.level == "error") | 
            "  - \(.ruleId): \(.message.text[:60])..."' \
            "$RESULTS_DIR/cert-results.sarif" | head -5
        echo ""
    fi
    
    echo "================================================"
    echo "End of Report"
    echo "================================================"
    
} | tee "$REPORT_FILE"

echo -e "\n${CYAN}Report saved to: $REPORT_FILE${NC}"

# Generate CSV exports
if [ -f "$RESULTS_DIR/misra-results.sarif" ]; then
    echo "Exporting MISRA violations to CSV..."
    jq -r '.runs[0].results[] | 
        [
            .ruleId,
            (.rule.properties.tags | 
            map(select(startswith("external/misra/obligation"))) | 
            .[0] // "N/A"),
            .message.text,
            .locations[0].physicalLocation.artifactLocation.uri,
            .locations[0].physicalLocation.region.startLine
        ] | @csv' \
        "$RESULTS_DIR/misra-results.sarif" \
        > "$RESULTS_DIR/misra-violations.csv"
    echo "  Saved to: $RESULTS_DIR/misra-violations.csv"
fi

if [ -f "$RESULTS_DIR/cert-results.sarif" ]; then
    echo "Exporting CERT violations to CSV..."
    jq -r '.runs[0].results[] | 
        [
            .ruleId,
            .level,
            .message.text,
            .locations[0].physicalLocation.artifactLocation.uri,
            .locations[0].physicalLocation.region.startLine
        ] | @csv' \
        "$RESULTS_DIR/cert-results.sarif" \
        > "$RESULTS_DIR/cert-violations.csv"
    echo "  Saved to: $RESULTS_DIR/cert-violations.csv"
fi
