#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$SCRIPT_DIR"
DB_PATH="${DB_DIR:-$LAB_DIR/../05-cpp-cmake-setup/databases/test-cpp-db}"
METRICS_ROOT="$HOME/.codeql-home/codeql/qlpacks/codeql/cpp-queries/1.5.10/Metrics"
OUT_DIR="$LAB_DIR/results/predefined"
SARIF_FILE="$OUT_DIR/predefined-metrics.sarif"

if [ ! -d "$DB_PATH" ]; then
  echo "Database not found: $DB_PATH"
  echo "Usage: DB_DIR=/path/to/database ./measure-predefined-metrics.sh"
  exit 1
fi

if [ ! -d "$METRICS_ROOT" ]; then
  echo "Metrics root not found: $METRICS_ROOT"
  exit 1
fi

mkdir -p "$OUT_DIR"

metric_queries=("codeql/cpp-queries:Metrics/Functions/FunCyclomaticComplexity.ql" \
    "codeql/cpp-queries:Metrics/Functions/FunLinesOfCode.ql" \
    "codeql/cpp-queries:Metrics/Functions/FunNumberOfCalls.ql" \
    "codeql/cpp-queries:Metrics/Functions/FunNumberOfStatements.ql" \
    "codeql/cpp-queries:Metrics/Functions/StatementNestingDepth.ql" \
    "codeql/cpp-queries:Metrics/Functions/FunIterationNestingDepth.ql" \
    "codeql/cpp-queries:Metrics/Functions/FunLinesOfComments.ql" \
    "codeql/cpp-queries:Metrics/Functions/FunNumberOfParameters.ql" \
    "codeql/cpp-queries:Metrics/Functions/FunPercentageOfComments.ql") 

echo "Measuring predefined C++ metrics"
echo "Database: $DB_PATH"
echo "Queries: ${#metric_queries[@]}"
echo ""

echo "Running predefined metric queries"
# TODO: This SARIF currently does not contain the metrics!?
codeql database analyze \
    --rerun \
    --format=sarif-latest \
    --output="$SARIF_FILE" \
    --threads=0 --ram=8192 \
    "$DB_PATH" \
    "${metric_queries[@]}"

echo ""
echo "Done."
echo "SARIF output: $SARIF_FILE"
