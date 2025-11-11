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

# Build jq filter
JQ_FILTER=".runs[0].results |= map(select("

CONDITIONS=()

if [ -n "$RULE" ]; then
    CONDITIONS+=(".ruleId == \"$RULE\"")
fi

if [ -n "$TAG" ]; then
    CONDITIONS+=("(.properties.tags // [] | contains([\"$TAG\"]))")
fi

if [ -n "$LEVEL" ]; then
    CONDITIONS+=(".level == \"$LEVEL\"")
fi

if [ -n "$PRECISION" ]; then
    CONDITIONS+=("(.properties.precision // \"\") == \"$PRECISION\"")
fi

if [ -n "$FILE_PATTERN" ]; then
    CONDITIONS+=("(.locations[0].physicalLocation.artifactLocation.uri | test(\"$FILE_PATTERN\"))")
fi

# Join conditions with "and"
FILTER_EXPR=""
for i in "${!CONDITIONS[@]}"; do
    if [ $i -gt 0 ]; then
        FILTER_EXPR="$FILTER_EXPR and "
    fi
    FILTER_EXPR="$FILTER_EXPR${CONDITIONS[$i]}"
done

JQ_FILTER="$JQ_FILTER$FILTER_EXPR))"

# Apply filter
if [ -n "$OUTPUT" ]; then
    jq "$JQ_FILTER" "$SARIF_FILE" > "$OUTPUT"
    echo "Filtered results saved to: $OUTPUT"
    echo "Count: $(jq '.runs[0].results | length' "$OUTPUT")"
else
    jq "$JQ_FILTER" "$SARIF_FILE"
fi
