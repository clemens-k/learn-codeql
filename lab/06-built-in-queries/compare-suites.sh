#!/bin/bash
# compare-suites.sh - Compare results from different query suites

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"

echo -e "${BLUE}📊 Query Suite Comparison Report${NC}"
echo "================================"
echo ""

# Function to analyze a language
analyze_language() {
    local lang=$1
    local prefix=$2
    
    local scanning="$RESULTS_DIR/${prefix}-code-scanning.sarif"
    local quality="$RESULTS_DIR/${prefix}-security-and-quality.sarif"
    local extended="$RESULTS_DIR/${prefix}-security-extended.sarif"
    
    if [ ! -f "$scanning" ]; then
        echo -e "${YELLOW}No $lang results found. Skipping.${NC}\n"
        return
    fi
    
    echo -e "${CYAN}=== $lang Results ===${NC}"
    echo ""
    
    # Count findings
    local scan_count=$(jq '.runs[0].results | length' "$scanning")
    local qual_count=$(jq '.runs[0].results | length' "$quality")
    local ext_count=$(jq '.runs[0].results | length' "$extended")
    
    echo "Total Findings:"
    echo "  code-scanning:          $scan_count findings"
    echo "  security-and-quality:   $qual_count findings"
    echo "  security-extended:      $ext_count findings"
    echo ""
    
    # Severity breakdown
    echo "Severity Breakdown (security-and-quality):"
    jq -r '.runs[0].results | group_by(.level) | 
        map("  \(.[0].level): \(length) findings") | .[]' \
        "$quality" 2>/dev/null || echo "  (unable to parse)"
    echo ""
    
    # High severity issues
    echo "High Severity Issues (score >= 8.0):"
    local high_sev=$(jq '[.runs[0].results[] | 
        select(.rule.properties."security-severity" >= 8.0)] | length' \
        "$quality" 2>/dev/null || echo "0")
    echo "  $high_sev critical issues"
    echo ""
    
    # Precision breakdown
    echo "Precision Breakdown (security-and-quality):"
    jq -r '.runs[0].results | 
        group_by(.rule.properties.precision) | 
        map("  \(.[0].rule.properties.precision // "unknown"): \
\(length) findings") | .[]' \
        "$quality" 2>/dev/null || echo "  (unable to parse)"
    echo ""
    
    # Top issues
    echo "Top 5 Issues by Security Severity:"
    jq -r '.runs[0].results | 
        sort_by(-.rule.properties."security-severity") | 
        limit(5; .[]) | 
        "  [\(.rule.properties."security-severity" // "N/A")] \
\(.ruleId): \(.message.text[:60])..."' \
        "$quality" 2>/dev/null || echo "  (unable to parse)"
    echo ""
    
    # CWE categories
    echo "Top CWE Categories:"
    jq -r '.runs[0].results | 
        map(.rule.properties.tags | 
        map(select(startswith("external/cwe")))) | 
        flatten | 
        group_by(.) | 
        map({cwe: .[0], count: length}) | 
        sort_by(-.count) | 
        limit(5; .[]) | 
        "  \(.cwe): \(.count) findings"' \
        "$quality" 2>/dev/null || echo "  (unable to parse)"
    echo ""
    
    echo "---"
    echo ""
}

# Check if results exist
if [ ! -d "$RESULTS_DIR" ] || [ -z "$(ls -A $RESULTS_DIR/*.sarif 2>/dev/null)" ]; then
    echo -e "${RED}No results found!${NC}"
    echo "Run ./run-all-suites.sh first."
    exit 1
fi

# Analyze each language
analyze_language "C++" "cpp"
analyze_language "Rust" "rust"

# Cross-suite comparison
echo -e "${CYAN}=== Cross-Suite Analysis ===${NC}"
echo ""

for lang_prefix in cpp rust; do
    scanning="$RESULTS_DIR/${lang_prefix}-code-scanning.sarif"
    quality="$RESULTS_DIR/${lang_prefix}-security-and-quality.sarif"
    extended="$RESULTS_DIR/${lang_prefix}-security-extended.sarif"
    
    if [ -f "$scanning" ] && [ -f "$quality" ] && [ -f "$extended" ]; then
        echo "${lang_prefix^^} Unique Findings:"
        
        # Rules in extended but not in quality
        extended_only=$(comm -13 \
            <(jq -r '.runs[0].results[].ruleId' "$quality" | sort | uniq) \
            <(jq -r '.runs[0].results[].ruleId' "$extended" | sort | uniq) \
            | wc -l)
        echo "  Extended-only rules: $extended_only"
        
        # Rules in quality but not in scanning
        quality_only=$(comm -13 \
            <(jq -r '.runs[0].results[].ruleId' "$scanning" | sort | uniq) \
            <(jq -r '.runs[0].results[].ruleId' "$quality" | sort | uniq) \
            | wc -l)
        echo "  Quality-only rules: $quality_only"
        
        echo ""
    fi
done

# Summary and recommendations
echo -e "${CYAN}=== Recommendations ===${NC}"
echo ""
echo "Suite Selection Guide:"
echo "  • Use code-scanning for:"
echo "    - CI/CD pipelines"
echo "    - Pull request checks"
echo "    - Fast feedback loops"
echo ""
echo "  • Use security-and-quality for:"
echo "    - Development workflows"
echo "    - Pre-release checks"
echo "    - Balanced coverage"
echo ""
echo "  • Use security-extended for:"
echo "    - Security audits"
echo "    - Deep analysis"
echo "    - Finding edge cases"
echo ""

# Save report
REPORT_FILE="$RESULTS_DIR/comparison-report.txt"
{
    echo "Query Suite Comparison Report"
    echo "Generated: $(date)"
    echo "=============================="
    echo ""
    
    for file in "$RESULTS_DIR"/*.sarif; do
        if [ -f "$file" ]; then
            echo "$(basename "$file"):"
            echo "  Total findings: $(jq '.runs[0].results | length' "$file")"
            echo "  Errors: $(jq '[.runs[0].results[] | 
                select(.level == "error")] | length' "$file")"
            echo "  Warnings: $(jq '[.runs[0].results[] | 
                select(.level == "warning")] | length' "$file")"
            echo ""
        fi
    done
} > "$REPORT_FILE"

echo -e "${GREEN}Report saved to: $REPORT_FILE${NC}"
