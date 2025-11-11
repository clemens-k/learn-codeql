#!/bin/bash
# extract-metrics.sh - Extract metrics from SARIF files

set -e

OUTPUT=""

# Parse arguments
SARIF_FILE=""
while [[ $# -gt 0 ]]; do
    case $1 in
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
    echo "Usage: $0 <sarif-file> [--output <file>]"
    exit 1
fi

mkdir -p metrics

# Extract comprehensive metrics
METRICS=$(jq '{
    timestamp: now | strftime("%Y-%m-%d %H:%M:%S"),
    source_file: "'"$SARIF_FILE"'",
    total_findings: (.runs[0].results | length),
    by_severity: (
        .runs[0].results |
        group_by(.level) |
        map({key: .[0].level, value: length}) |
        from_entries
    ),
    by_precision: (
        .runs[0].results |
        group_by(.properties.precision // "unknown") |
        map({key: (.[0].properties.precision // "unknown"), value: length}) |
        from_entries
    ),
    top_10_rules: (
        .runs[0].results |
        group_by(.ruleId) |
        map({rule: .[0].ruleId, count: length}) |
        sort_by(-.count) |
        limit(10; .[])
    ),
    files_affected: (
        [.runs[0].results[].locations[0].physicalLocation.artifactLocation.uri] |
        unique |
        length
    ),
    most_affected_files: (
        .runs[0].results |
        group_by(.locations[0].physicalLocation.artifactLocation.uri) |
        map({file: .[0].locations[0].physicalLocation.artifactLocation.uri, issues: length}) |
        sort_by(-.issues) |
        limit(5; .[])
    )
}' "$SARIF_FILE")

# Output
if [ -n "$OUTPUT" ]; then
    echo "$METRICS" > "$OUTPUT"
    echo "Metrics saved to: $OUTPUT"
else
    echo "$METRICS"
fi
