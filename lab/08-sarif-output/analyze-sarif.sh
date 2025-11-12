#!/bin/bash
# analyze-sarif.sh - Basic SARIF file analysis

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <sarif-file>"
    echo ""
    echo "Performs basic analysis of a SARIF file"
    exit 1
fi

SARIF_FILE=$1

if [ ! -f "$SARIF_FILE" ]; then
    echo "Error: File not found: $SARIF_FILE"
    exit 1
fi

echo "SARIF File Analysis"
echo "==================="
echo "File: $SARIF_FILE"
echo ""

# Basic info
echo "## Document Information"
VERSION=$(jq -r '.version' "$SARIF_FILE")
SCHEMA=$(jq -r '."$schema"' "$SARIF_FILE")
echo "Version: $VERSION"
echo "Schema: $SCHEMA"
echo ""

# Tool info
echo "## Tool Information"
jq -r '.runs[0].tool.driver | 
    "Name: \(.name)\nVersion: \(.version // "N/A")\nOrganization: \(.organization // "N/A")"' \
    "$SARIF_FILE"
echo ""

# Results summary
echo "## Results Summary"
TOTAL=$(jq '.runs[0].results | length' "$SARIF_FILE")
echo "Total Findings: $TOTAL"
echo ""

if [ "$TOTAL" -gt 0 ]; then
    echo "By Severity:"
    jq -r '.runs[0].results | 
        group_by(.level) | 
        map("  \(.[0].level): \(length)") | 
        .[]' "$SARIF_FILE"
    echo ""
    
    echo "By Precision:"
    jq -r '.runs[0].results | 
        group_by(.properties.precision // "unknown") |
        map("  \(.[0].properties.precision // "unknown"): \(length)") |
        .[]' "$SARIF_FILE"
    echo ""
    
    echo "Top 5 Rules:"
    jq -r '.runs[0].results | 
        group_by(.ruleId) | 
        map({rule: .[0].ruleId, count: length}) | 
        sort_by(-.count) | 
        limit(5; .[]) | 
        "  \(.count)x \(.rule)"' "$SARIF_FILE"
    echo ""
    
    echo "Top 5 Files:"
    jq -r '.runs[0].results | 
        group_by(.locations[0].physicalLocation.artifactLocation.uri) |
        map({file: .[0].locations[0].physicalLocation.artifactLocation.uri, count: length}) |
        sort_by(-.count) |
        limit(5; .[]) |
        "  \(.count) issues: \(.file)"' "$SARIF_FILE"
fi
