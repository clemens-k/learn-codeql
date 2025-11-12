#!/bin/bash
# create-baseline.sh - Create and manage baseline SARIF files

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <sarif-file>"
    echo ""
    echo "Creates a baseline from a SARIF file for tracking changes"
    exit 1
fi

SARIF_FILE=$1

if [ ! -f "$SARIF_FILE" ]; then
    echo "Error: File not found: $SARIF_FILE"
    exit 1
fi

# Create baselines directory
mkdir -p baselines

# Generate baseline filename
TIMESTAMP=$(date +%Y%m%d)
BASELINE="baselines/baseline-$TIMESTAMP.sarif"

# Check if baseline already exists
if [ -f "$BASELINE" ]; then
    echo "Baseline for today already exists: $BASELINE"
    read -p "Overwrite? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Copy to baseline
cp "$SARIF_FILE" "$BASELINE"

# Create symlink to latest
ln -sf "$(basename "$BASELINE")" baselines/baseline-latest.sarif

echo "✅ Baseline created: $BASELINE"
echo ""

# Show summary
TOTAL=$(jq '.runs[0].results | length' "$BASELINE")
ERRORS=$(jq '[.runs[0].results[] | select(.level == "error")] | length' "$BASELINE")
WARNINGS=$(jq '[.runs[0].results[] | select(.level == "warning")] | length' "$BASELINE")

echo "Baseline Summary:"
echo "  Total findings: $TOTAL"
echo "  Errors:         $ERRORS"
echo "  Warnings:       $WARNINGS"
echo ""
echo "Compare future scans against this baseline:"
echo "  ./compare-scans.sh $BASELINE new-scan.sarif"
