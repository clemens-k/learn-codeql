#!/bin/bash
# Analyze Rust database with CodeQL

set -e

CODEQL_HOME="$HOME/.codeql-home"
DB_DIR="$(pwd)/databases/test-rust-db"
RESULTS_DIR="$(pwd)/results"
QUERY_SUITE="$CODEQL_HOME/codeql-repo/rust/ql/src/codeql-suites/rust-security-and-quality.qls"

echo "🦀 Analyzing Rust Database with CodeQL"
echo "======================================="
echo ""

# Check database exists
if [ ! -d "$DB_DIR" ]; then
    echo "❌ Database not found: $DB_DIR"
    echo "Run ./create-rust-database.sh first"
    exit 1
fi

# Create results directory
mkdir -p "$RESULTS_DIR"

# Run analysis
echo "🚀 Running security and quality analysis..."
echo "Query suite: rust-security-and-quality"
echo ""

codeql database analyze "$DB_DIR" \
    "$QUERY_SUITE" \
    --format=sarif-latest \
    --output="$RESULTS_DIR/rust-results.sarif" \
    --threads=4 \
    --ram=8192

echo ""
echo "✅ Analysis complete!"
echo ""
echo "📄 Results saved to: $RESULTS_DIR/rust-results.sarif"
echo ""

# Show summary
if command -v jq &> /dev/null; then
    echo "📊 Summary:"
    RESULT_COUNT=$(jq '.runs[0].results | length' "$RESULTS_DIR/rust-results.sarif")
    echo "  Found $RESULT_COUNT issues"
    echo ""
    echo "Top issues:"
    jq -r '.runs[0].results[0:5] | .[] | "  - \(.ruleId): \(.message.text)"' "$RESULTS_DIR/rust-results.sarif" 2>/dev/null || echo "  (install jq for detailed summary)"
fi

echo ""
echo "View results:"
echo "  1. In terminal: cat $RESULTS_DIR/rust-results.sarif | jq"
echo "  2. In VS Code: code $RESULTS_DIR/rust-results.sarif"
echo "  3. Raw: cat $RESULTS_DIR/rust-results.sarif"
