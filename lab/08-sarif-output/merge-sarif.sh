#!/bin/bash
# merge-sarif.sh - Merge multiple SARIF files

set -e

DEDUPLICATE=false
OUTPUT=""
INPUT_FILES=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --deduplicate)
            DEDUPLICATE=true
            shift
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        *)
            INPUT_FILES+=("$1")
            shift
            ;;
    esac
done

if [ ${#INPUT_FILES[@]} -lt 2 ]; then
    echo "Usage: $0 <sarif1> <sarif2> [sarif3...] [options]"
    echo ""
    echo "Options:"
    echo "  --deduplicate    Remove duplicate findings"
    echo "  --output <file>  Output file (required)"
    exit 1
fi

if [ -z "$OUTPUT" ]; then
    echo "Error: --output is required"
    exit 1
fi

echo "Merging ${#INPUT_FILES[@]} SARIF files..."

if [ "$DEDUPLICATE" = true ]; then
    # Merge with deduplication
    jq -s '
        {
            version: .[0].version,
            "$schema": .[0]."$schema",
            runs: [{
                tool: .[0].runs[0].tool,
                results: (
                    [.[].runs[].results[]] | 
                    unique_by(
                        .ruleId + ":" +
                        .locations[0].physicalLocation.artifactLocation.uri + ":" +
                        (.locations[0].physicalLocation.region.startLine | tostring)
                    )
                )
            }]
        }
    ' "${INPUT_FILES[@]}" > "$OUTPUT"
else
    # Simple merge (keep all runs)
    jq -s '
        {
            version: .[0].version,
            "$schema": .[0]."$schema",
            runs: [.[].runs[]]
        }
    ' "${INPUT_FILES[@]}" > "$OUTPUT"
fi

echo "✅ Merged SARIF saved to: $OUTPUT"
echo ""
echo "Statistics:"
for file in "${INPUT_FILES[@]}"; do
    COUNT=$(jq '.runs[0].results | length' "$file")
    echo "  $file: $COUNT findings"
done
echo ""
MERGED_COUNT=$(jq '[.runs[].results[]] | length' "$OUTPUT")
echo "  $OUTPUT: $MERGED_COUNT findings (total)"
