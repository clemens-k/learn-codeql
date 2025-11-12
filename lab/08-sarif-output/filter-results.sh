#!/bin/bash
# filter-results.sh - Filter SARIF results by various criteria

set -e

RULE=""
TAG=""
LEVEL=""
PRECISION=""
FILE_PATTERN=""
OUTPUT=""

# Parse arguments
SARIF_FILE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --rule)
            RULE="$2"
            shift 2
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        --level)
            LEVEL="$2"
            shift 2
            ;;
        --precision)
            PRECISION="$2"
            shift 2
            ;;
        --file)
            FILE_PATTERN="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        *)
            if [ -z "$SARIF_FILE" ]; then
                SARIF_FILE="$1"
            else
                echo "Unexpected argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$SARIF_FILE" ]; then
    echo "Usage: $0 <sarif-file> [filters]"
    echo ""
    echo "Filters:"
    echo "  --rule <rule-id>         Filter by rule ID"
    echo "  --tag <tag>              Filter by tag"
    echo "  --level <level>          Filter by level (error, warning, note)"
    echo "  --precision <precision>  Filter by precision (high, medium, low)"
    echo "  --file <pattern>         Filter by file path pattern"
    echo "  --output <file>          Output file"
    exit 1
fi


# Robust: Join results with rules for tag/precision filtering, default missing fields
JQ_JOIN='def join_results_with_rules:
  . as $sarif |
  ($sarif.runs[0].tool.driver.rules // []) as $rules |
  ($sarif.runs[0].results // []) | map(
    . as $result |
    ($rules[] | select(.id == $result.ruleId)) as $rule |
    $result + { _rule: $rule }
  );
join_results_with_rules'

# Build jq filter expression as a string
COND='true'
if [ -n "$RULE" ]; then
    COND="$COND and (.ruleId == \"$RULE\")"
fi
if [ -n "$TAG" ]; then
    COND="$COND and ((._rule.properties.tags // []) | contains([\"$TAG\"]))"
fi
if [ -n "$LEVEL" ]; then
    COND="$COND and ((.level // \"unknown\") == \"$LEVEL\")"
fi
if [ -n "$PRECISION" ]; then
    COND="$COND and ((._rule.properties.precision // \"unknown\") == \"$PRECISION\")"
fi
if [ -n "$FILE_PATTERN" ]; then
    COND="$COND and ((.locations[0].physicalLocation.artifactLocation.uri // \"\") | test(\"$FILE_PATTERN\"))"
fi

# Compose the full jq filter
JQ_FILTER="$JQ_JOIN | map(select($COND)) | { runs: [ { results: ., tool: { driver: {} } } ] }"

if [ -n "$OUTPUT" ]; then
    jq "$JQ_FILTER" "$SARIF_FILE" > "$OUTPUT"
    echo "Filtered results saved to: $OUTPUT"
    echo "Count: $(jq '.runs[0].results | length' "$OUTPUT")"
else
    jq "$JQ_FILTER" "$SARIF_FILE"
fi
