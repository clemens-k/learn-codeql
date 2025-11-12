#!/bin/bash
# compare-scans.sh - Compare two SARIF files

set -e

FORMAT="summary"
OUTPUT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        *)
            if [ -z "$BASELINE" ]; then
                BASELINE="$1"
            elif [ -z "$CURRENT" ]; then
                CURRENT="$1"
            else
                echo "Unexpected argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$BASELINE" ] || [ -z "$CURRENT" ]; then
    echo "Usage: $0 <baseline.sarif> <current.sarif> [options]"
    echo ""
    echo "Options:"
    echo "  --format <type>    Output format: summary, detailed, new-only"
    echo "  --output <file>    Output file (default: stdout)"
    exit 1
fi

# Create unique ID for each finding
create_id() {
    jq -r '.runs[0].results[] | 
        "\(.ruleId):\(.locations[0].physicalLocation.artifactLocation.uri):\(.locations[0].physicalLocation.region.startLine)"' \
        "$1" | sort
}

# Extract IDs
BASELINE_IDS=$(create_id "$BASELINE")
CURRENT_IDS=$(create_id "$CURRENT")

# Calculate differences
NEW_COUNT=$(comm -13 <(echo "$BASELINE_IDS") <(echo "$CURRENT_IDS") | wc -l)
FIXED_COUNT=$(comm -23 <(echo "$BASELINE_IDS") <(echo "$CURRENT_IDS") | wc -l)
UNCHANGED_COUNT=$(comm -12 <(echo "$BASELINE_IDS") <(echo "$CURRENT_IDS") | wc -l)

# Generate output
generate_summary() {
    echo "Scan Comparison Report"
    echo "======================"
    echo ""
    echo "Baseline: $BASELINE"
    echo "Current:  $CURRENT"
    echo ""
    echo "## Summary"
    echo "New Issues:       $NEW_COUNT"
    echo "Fixed Issues:     $FIXED_COUNT"
    echo "Unchanged Issues: $UNCHANGED_COUNT"
    echo ""
    
    if [ "$NEW_COUNT" -gt 0 ]; then
        echo "## New Issues"
        comm -13 <(echo "$BASELINE_IDS") <(echo "$CURRENT_IDS") | head -10
        if [ "$NEW_COUNT" -gt 10 ]; then
            echo "... and $((NEW_COUNT - 10)) more"
        fi
        echo ""
    fi
    
    if [ "$FIXED_COUNT" -gt 0 ]; then
        echo "## Fixed Issues"
        comm -23 <(echo "$BASELINE_IDS") <(echo "$CURRENT_IDS") | head -10
        if [ "$FIXED_COUNT" -gt 10 ]; then
            echo "... and $((FIXED_COUNT - 10)) more"
        fi
    fi
}

generate_new_only() {
    # Extract new findings into SARIF
    NEW_IDS=$(comm -13 <(echo "$BASELINE_IDS") <(echo "$CURRENT_IDS"))
    
    jq --arg new_ids "$NEW_IDS" '
        .runs[0].results |= map(
            . as $result |
            ($result.ruleId + ":" + 
             $result.locations[0].physicalLocation.artifactLocation.uri + ":" +
             ($result.locations[0].physicalLocation.region.startLine | tostring)) as $id |
            select($new_ids | contains($id))
        )
    ' "$CURRENT"
}

# Output
if [ "$FORMAT" = "new-only" ]; then
    if [ -n "$OUTPUT" ]; then
        generate_new_only > "$OUTPUT"
        echo "New findings saved to: $OUTPUT"
    else
        generate_new_only
    fi
else
    if [ -n "$OUTPUT" ]; then
        generate_summary > "$OUTPUT"
        echo "Comparison report saved to: $OUTPUT"
    else
        generate_summary
    fi
fi
