#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$SCRIPT_DIR"
DB_PATH="${DB_DIR:-$LAB_DIR/../05-cpp-cmake-setup/databases/test-cpp-db}"
PACK_DIR="$LAB_DIR/code-complexity"
SUITE_FILE="$PACK_DIR/suites/thresholds.qls"
OUT_DIR="$LAB_DIR/results/thresholds"
SARIF_FILE="$OUT_DIR/threshold-metrics.sarif"
CSV_FILE="$OUT_DIR/threshold-metrics.csv"

if [ ! -d "$DB_PATH" ]; then
  echo "Database not found: $DB_PATH"
  echo "Usage: DB_DIR=/path/to/database ./apply-metric-thresholds.sh"
  exit 1
fi

mkdir -p "$OUT_DIR"

echo "Applying metric thresholds"
echo "Database: $DB_PATH"
echo "Suite: $SUITE_FILE"
echo ""

codeql database analyze \
  --rerun \
  "$DB_PATH" \
  "$SUITE_FILE" \
  --format=sarif-latest \
  --output="$SARIF_FILE"

codeql database analyze \
  "$DB_PATH" \
  "$SUITE_FILE" \
  --format=csv \
  --output="$CSV_FILE"


echo ""
echo "Done."
echo "CSV output:   $CSV_FILE"
echo "SARIF output: $SARIF_FILE"