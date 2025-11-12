#!/bin/bash
# filter-by-obligation.sh - Filter MISRA results by obligation level

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <sarif-file> <obligation>"
    echo ""
    echo "Obligation levels:"
    echo "  required  - Required rules (critical)"
    echo "  advisory  - Advisory rules (recommended)"
    echo ""
    echo "Example:"
    echo "  $0 results/misra-results.sarif required"
    exit 1
fi

SARIF_FILE=$1
OBLIGATION=$2

if [ ! -f "$SARIF_FILE" ]; then
    echo "Error: File not found: $SARIF_FILE"
    exit 1
fi

BASENAME=$(basename "$SARIF_FILE" .sarif)
OUTPUT_DIR="$(dirname "$SARIF_FILE")"
OUTPUT="$OUTPUT_DIR/${BASENAME}-${OBLIGATION}.sarif"

echo "Filtering by obligation: $OBLIGATION"


jq --arg obligation "external/misra/obligation/$OBLIGATION" '
    .runs[0] as $run |
    $run.results as $results |
    $run.tool.driver.rules as $rules |
    .runs[0].results = [
        $results[] as $r |
        ($rules[] | select(.id? == $r.ruleId and .properties?.tags? and (.properties.tags | index($obligation)))) as $rule |
        $r
    ]
' "$SARIF_FILE" > "$OUTPUT"

COUNT=$(jq '.runs[0].results | length' "$OUTPUT")

echo "Filtered: $(jq '.runs[0].results | length' "$SARIF_FILE") → $COUNT findings"
echo "Output: $OUTPUT"
echo ""

if [ "$COUNT" -gt 0 ]; then
    echo "Sample results:"
    jq -r '.runs[0].results | limit(5; .[]) | 
        "  \(.ruleId): \(.message.text[:60])..."' "$OUTPUT"
fi
