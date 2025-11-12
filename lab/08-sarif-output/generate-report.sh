#!/bin/bash
# generate-report.sh - Generate reports from SARIF files

set -e

FORMAT="summary"
OUTPUT=""

# Parse arguments
SARIF_FILE=""
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
    echo "Usage: $0 <sarif-file> [options]"
    echo ""
    echo "Options:"
    echo "  --format <type>   Report format: summary, html, csv"
    echo "  --output <file>   Output file (default: stdout)"
    exit 1
fi

mkdir -p reports

generate_summary() {
    echo "CodeQL Security Scan Report"
    echo "==========================="
    echo ""
    echo "Generated: $(date)"
    echo "Source: $SARIF_FILE"
    echo ""
    
    TOTAL=$(jq '.runs[0].results | length' "$SARIF_FILE")
    ERRORS=$(jq '[.runs[0].results[] | select(.level == "error")] | length' "$SARIF_FILE")
    WARNINGS=$(jq '[.runs[0].results[] | select(.level == "warning")] | length' "$SARIF_FILE")
    NOTES=$(jq '[.runs[0].results[] | select(.level == "note")] | length' "$SARIF_FILE")
    
    echo "## Summary"
    echo "Total Findings: $TOTAL"
    echo "  Errors:   $ERRORS"
    echo "  Warnings: $WARNINGS"
    echo "  Notes:    $NOTES"
    echo ""
    
    echo "## Top 10 Rules"
    jq -r '.runs[0].results | 
        group_by(.ruleId) |
        map({rule: .[0].ruleId, count: length, message: .[0].message.text}) |
        sort_by(-.count) |
        limit(10; .[]) |
        "\(.count)x \(.rule)\n    \(.message)\n"' "$SARIF_FILE"
    
    echo "## Most Affected Files"
    jq -r '.runs[0].results |
        group_by(.locations[0].physicalLocation.artifactLocation.uri) |
        map({file: .[0].locations[0].physicalLocation.artifactLocation.uri, count: length}) |
        sort_by(-.count) |
        limit(10; .[]) |
        "  \(.count) issues: \(.file)"' "$SARIF_FILE"
}

generate_csv() {
    jq -r '
        ["Rule ID", "Level", "File", "Line", "Message", "Precision"] as $header |
        ($header | @csv),
        (.runs[0].results[] |
            [
                .ruleId,
                .level,
                .locations[0].physicalLocation.artifactLocation.uri,
                .locations[0].physicalLocation.region.startLine,
                .message.text,
                (.properties.precision // "N/A")
            ] | @csv
        )
    ' "$SARIF_FILE"
}

generate_html() {
    cat << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>CodeQL Scan Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #2c3e50; }
        .summary { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .error { color: #e74c3c; font-weight: bold; }
        .warning { color: #f39c12; font-weight: bold; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #34495e; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .filename { font-family: monospace; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>CodeQL Security Scan Report</h1>
    <p><strong>Generated:</strong> $(date)</p>
    <p><strong>Source:</strong> $SARIF_FILE</p>
EOF

    TOTAL=$(jq '.runs[0].results | length' "$SARIF_FILE")
    ERRORS=$(jq '[.runs[0].results[] | select(.level == "error")] | length' "$SARIF_FILE")
    WARNINGS=$(jq '[.runs[0].results[] | select(.level == "warning")] | length' "$SARIF_FILE")
    
    cat << EOF
    <div class="summary">
        <h2>Summary</h2>
        <p><strong>Total Findings:</strong> $TOTAL</p>
        <p class="error">Errors: $ERRORS</p>
        <p class="warning">Warnings: $WARNINGS</p>
    </div>
    
    <h2>Findings</h2>
    <table>
        <tr>
            <th>Severity</th>
            <th>Rule</th>
            <th>File</th>
            <th>Line</th>
            <th>Message</th>
        </tr>
EOF

    jq -r '.runs[0].results[] |
        "<tr class=\"\(.level)\">
            <td>\(.level)</td>
            <td>\(.ruleId)</td>
            <td class=\"filename\">\(.locations[0].physicalLocation.artifactLocation.uri)</td>
            <td>\(.locations[0].physicalLocation.region.startLine)</td>
            <td>\(.message.text)</td>
        </tr>"' "$SARIF_FILE"
    
    cat << 'EOF'
    </table>
</body>
</html>
EOF
}

# Generate report
case $FORMAT in
    summary)
        if [ -n "$OUTPUT" ]; then
            generate_summary > "$OUTPUT"
            echo "Summary report saved to: $OUTPUT"
        else
            generate_summary
        fi
        ;;
    csv)
        if [ -n "$OUTPUT" ]; then
            generate_csv > "$OUTPUT"
            echo "CSV report saved to: $OUTPUT"
        else
            generate_csv
        fi
        ;;
    html)
        if [ -n "$OUTPUT" ]; then
            generate_html > "$OUTPUT"
            echo "HTML report saved to: $OUTPUT"
        else
            generate_html
        fi
        ;;
    *)
        echo "Unknown format: $FORMAT"
        exit 1
        ;;
esac
