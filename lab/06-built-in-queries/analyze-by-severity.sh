#!/bin/bash
# analyze-by-severity.sh - Analyze SARIF results by severity

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo "Usage: $0 <sarif-file>"
    echo ""
    echo "Example:"
    echo "  $0 results/cpp-security-and-quality.sarif"
    exit 1
fi

SARIF_FILE=$1

if [ ! -f "$SARIF_FILE" ]; then
    echo -e "${RED}Error: File not found: $SARIF_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}📊 Severity Analysis${NC}"
echo "===================="
echo "File: $(basename "$SARIF_FILE")"
echo ""

# Count by level
echo -e "${CYAN}Findings by Level:${NC}"
jq -r '.runs[0].results | group_by(.level) | 
    map("\u001b[0;36m\(.[0].level):\u001b[0m \(length) findings") | 
    .[]' "$SARIF_FILE"
echo ""

# Count by security severity
echo -e "${CYAN}Security Severity Distribution:${NC}"
echo "Critical (>= 9.0): $(jq '[.runs[0].results[] | 
    select(.rule.properties."security-severity" >= 9.0)] | length' \
    "$SARIF_FILE")"
echo "High (8.0-8.9):    $(jq '[.runs[0].results[] | 
    select(.rule.properties."security-severity" >= 8.0 and 
    .rule.properties."security-severity" < 9.0)] | length' \
    "$SARIF_FILE")"
echo "Medium (5.0-7.9):  $(jq '[.runs[0].results[] | 
    select(.rule.properties."security-severity" >= 5.0 and 
    .rule.properties."security-severity" < 8.0)] | length' \
    "$SARIF_FILE")"
echo "Low (< 5.0):       $(jq '[.runs[0].results[] | 
    select(.rule.properties."security-severity" < 5.0)] | length' \
    "$SARIF_FILE")"
echo ""

# Count by precision
echo -e "${CYAN}Findings by Precision:${NC}"
jq -r '.runs[0].results | 
    group_by(.rule.properties.precision) | 
    map("\(.[ 0].rule.properties.precision // "unknown"): \(length) findings") | .[]' "$SARIF_FILE"
echo ""

# Top issues
echo -e "${CYAN}Top 10 Issues by Security Severity:${NC}"
jq -r '.runs[0].results | 
    map(select(.rule.properties."security-severity" != null)) |
    sort_by(-.rule.properties."security-severity") | 
    limit(10; .[]) | 
    "[\(.rule.properties."security-severity" // "N/A" | tostring | .[0:4])] \(.ruleId)\n  \(.message.text)\n  Location: \(.locations[0].physicalLocation.artifactLocation.uri):\(.locations[0].physicalLocation.region.startLine)\n"' \
    "$SARIF_FILE"

# Error-level issues
echo -e "${CYAN}Error-Level Issues:${NC}"
error_count=$(jq '[.runs[0].results[] | 
    select(.level == "error")] | length' "$SARIF_FILE")
echo "Total: $error_count"
echo ""

if [ "$error_count" -gt 0 ]; then
    jq -r '.runs[0].results[] | 
        select(.level == "error") | 
        "🔴 \(.ruleId)\n   \(.message.text)\n   \(.locations[0].physicalLocation.artifactLocation.uri):\(.locations[0].physicalLocation.region.startLine)\n"' \
        "$SARIF_FILE" | head -20
fi

# Summary statistics
echo -e "${CYAN}Summary Statistics:${NC}"
echo "Total findings:     $(jq '.runs[0].results | length' "$SARIF_FILE")"
echo "Unique rules:       $(jq '[.runs[0].results[].ruleId] | 
    unique | length' "$SARIF_FILE")"
echo "Affected files:     $(jq '[.runs[0].results[].locations[].physicalLocation.artifactLocation.uri] | 
    unique | length' "$SARIF_FILE")"
echo ""

# Recommendations
echo -e "${CYAN}Priority Recommendations:${NC}"
echo ""
echo "Fix immediately (Error + High Severity):"
jq '[.runs[0].results[] | 
    select(.level == "error" and 
    .rule.properties."security-severity" >= 8.0)] | length' \
    "$SARIF_FILE" | \
    xargs -I {} echo "  {} critical issues"

echo ""
echo "Fix this sprint (Error + Medium Severity):"
jq '[.runs[0].results[] | 
    select(.level == "error" and 
    .rule.properties."security-severity" >= 5.0 and 
    .rule.properties."security-severity" < 8.0)] | length' \
    "$SARIF_FILE" | \
    xargs -I {} echo "  {} important issues"

echo ""
echo "Technical debt (Warnings):"
jq '[.runs[0].results[] | 
    select(.level == "warning")] | length' \
    "$SARIF_FILE" | \
    xargs -I {} echo "  {} issues to address"
