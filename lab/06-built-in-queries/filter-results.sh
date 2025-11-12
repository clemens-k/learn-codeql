#!/bin/bash
# filter-results.sh - Filter SARIF results by various criteria

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo "Usage: $0 <sarif-file> [filter-type] [value]"
    echo ""
    echo "Filter types:"
    echo "  severity <error|warning|note>"
    echo "  precision <very-high|high|medium|low>"
    echo "  score <min-score>          # Min security severity (0.0-10.0)"
    echo "  cwe <cwe-number>           # e.g., cwe-119"
    echo "  path <path-pattern>        # e.g., src/"
    echo ""
    echo "Examples:"
    echo "  $0 results/cpp-security-and-quality.sarif severity error"
    echo "  $0 results/rust-security-extended.sarif precision very-high"
    echo "  $0 results/cpp-code-scanning.sarif score 8.0"
    echo "  $0 results/cpp-security-and-quality.sarif cwe cwe-119"
    exit 1
fi

SARIF_FILE=$1
FILTER_TYPE=$2
FILTER_VALUE=$3

if [ ! -f "$SARIF_FILE" ]; then
    echo -e "${RED}Error: File not found: $SARIF_FILE${NC}"
    exit 1
fi

BASENAME=$(basename "$SARIF_FILE" .sarif)
OUTPUT_DIR="$(dirname "$SARIF_FILE")"

# Apply filter based on type
case "$FILTER_TYPE" in
    severity)
        echo -e "${BLUE}Filtering by severity: $FILTER_VALUE${NC}"
        OUTPUT="$OUTPUT_DIR/${BASENAME}-${FILTER_VALUE}.sarif"
        
        jq --arg level "$FILTER_VALUE" \
            '.runs[0].results |= map(select(.level == $level))' \
            "$SARIF_FILE" > "$OUTPUT"
        ;;
        
    precision)
        echo -e "${BLUE}Filtering by precision: $FILTER_VALUE${NC}"
        OUTPUT="$OUTPUT_DIR/${BASENAME}-precision-${FILTER_VALUE}.sarif"
        
        jq --arg prec "$FILTER_VALUE" \
            '.runs[0].results |= 
            map(select(.rule.properties.precision == $prec))' \
            "$SARIF_FILE" > "$OUTPUT"
        ;;
        
    score)
        echo -e "${BLUE}Filtering by min security score: $FILTER_VALUE${NC}"
        OUTPUT="$OUTPUT_DIR/${BASENAME}-score-${FILTER_VALUE}+.sarif"
        
        jq --argjson score "$FILTER_VALUE" \
            '.runs[0].results |= 
            map(select(.rule.properties."security-severity" >= $score))' \
            "$SARIF_FILE" > "$OUTPUT"
        ;;
        
    cwe)
        echo -e "${BLUE}Filtering by CWE: $FILTER_VALUE${NC}"
        OUTPUT="$OUTPUT_DIR/${BASENAME}-${FILTER_VALUE}.sarif"
        
        jq --arg cwe "external/cwe/$FILTER_VALUE" \
            '.runs[0].results |= 
            map(select(.rule.properties.tags | contains([$cwe])))' \
            "$SARIF_FILE" > "$OUTPUT"
        ;;
        
    path)
        echo -e "${BLUE}Filtering by path pattern: $FILTER_VALUE${NC}"
        SAFE_PATH=$(echo "$FILTER_VALUE" | sed 's/\//-/g')
        OUTPUT="$OUTPUT_DIR/${BASENAME}-path-${SAFE_PATH}.sarif"
        
        jq --arg path "$FILTER_VALUE" \
            '.runs[0].results |= 
            map(select(.locations[0].physicalLocation.
            artifactLocation.uri | startswith($path)))' \
            "$SARIF_FILE" > "$OUTPUT"
        ;;
        
    *)
        if [ -z "$FILTER_TYPE" ]; then
            # Interactive mode
            echo -e "${CYAN}Filter Results Menu${NC}"
            echo "==================="
            echo ""
            echo "1. By severity level (error/warning/note)"
            echo "2. By precision (very-high/high/medium/low)"
            echo "3. By security severity score (0.0-10.0)"
            echo "4. By CWE category"
            echo "5. By file path pattern"
            echo "6. Show available CWEs"
            echo "7. Show available file paths"
            echo ""
            read -p "Select option (1-7): " choice
            
            case $choice in
                1)
                    read -p "Enter severity (error/warning/note): " sev
                    exec "$0" "$SARIF_FILE" severity "$sev"
                    ;;
                2)
                    read -p "Enter precision (very-high/high/medium/low): " prec
                    exec "$0" "$SARIF_FILE" precision "$prec"
                    ;;
                3)
                    read -p "Enter minimum score (0.0-10.0): " score
                    exec "$0" "$SARIF_FILE" score "$score"
                    ;;
                4)
                    echo ""
                    echo "Available CWEs in this file:"
                    jq -r '.runs[0].results[].rule.properties.tags | 
                        map(select(startswith("external/cwe"))) | 
                        .[]' "$SARIF_FILE" | sort | uniq | head -20
                    echo ""
                    read -p "Enter CWE (e.g., cwe-119): " cwe
                    exec "$0" "$SARIF_FILE" cwe "$cwe"
                    ;;
                5)
                    echo ""
                    echo "Available paths in this file:"
                    jq -r '.runs[0].results[].locations[0].
                        physicalLocation.artifactLocation.uri' \
                        "$SARIF_FILE" | sort | uniq | head -20
                    echo ""
                    read -p "Enter path pattern (e.g., src/): " path
                    exec "$0" "$SARIF_FILE" path "$path"
                    ;;
                6)
                    echo ""
                    echo "CWE Distribution:"
                    jq -r '.runs[0].results | 
                        map(.rule.properties.tags | 
                        map(select(startswith("external/cwe")))) | 
                        flatten | 
                        group_by(.) | 
                        map("\(.[ 0]): \(length) findings") | 
                        .[]' "$SARIF_FILE"
                    exit 0
                    ;;
                7)
                    echo ""
                    echo "File Distribution:"
                    jq -r '.runs[0].results | 
                        group_by(.locations[0].physicalLocation.
                        artifactLocation.uri) | 
                        map("\(.[ 0].locations[0].physicalLocation.
                        artifactLocation.uri): \(length) findings") | 
                        .[]' "$SARIF_FILE"
                    exit 0
                    ;;
                *)
                    echo "Invalid option"
                    exit 1
                    ;;
            esac
        else
            echo -e "${RED}Unknown filter type: $FILTER_TYPE${NC}"
            echo "Use: severity, precision, score, cwe, or path"
            exit 1
        fi
        ;;
esac

# Show results
if [ -f "$OUTPUT" ]; then
    COUNT=$(jq '.runs[0].results | length' "$OUTPUT")
    ORIGINAL=$(jq '.runs[0].results | length' "$SARIF_FILE")
    
    echo -e "${GREEN}✓ Filtered: $ORIGINAL → $COUNT findings${NC}"
    echo -e "${BLUE}Output: $OUTPUT${NC}"
    echo ""
    
    # Show sample results
    if [ "$COUNT" -gt 0 ]; then
        echo "Sample results:"
        jq -r '.runs[0].results | limit(5; .[]) | 
            "  \(.ruleId): \(.message.text[:60])..."' "$OUTPUT"
    fi
fi
