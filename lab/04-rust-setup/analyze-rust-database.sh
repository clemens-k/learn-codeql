#!/bin/bash
# Analyze Rust database with CodeQL

set -e

CODEQL_HOME="${CODEQL_HOME:-$HOME/.codeql-home}"
DB_DIR="$(pwd)/databases/test-rust-db"
RESULTS_DIR="$(pwd)/results"
QUERY_SUITE="codeql/rust-queries"

echo "🦀 Analyzing Rust Database with CodeQL"
echo "======================================="
echo ""

# Check CodeQL exists
if [ ! -f "$CODEQL_HOME/codeql/codeql" ]; then
    echo "❌ CodeQL not found at: $CODEQL_HOME/codeql/codeql"
    echo "💡 Run ../03-installation/install-codeql.sh first"
    echo "💡 Or set CODEQL_HOME environment variable"
    exit 1
fi

# Check database exists
if [ ! -d "$DB_DIR" ]; then
    echo "❌ Database not found: $DB_DIR"
    echo "💡 Run ./create-rust-database.sh first"
    exit 1
fi

echo "✓ CodeQL found: $CODEQL_HOME/codeql/codeql"
echo "✓ Database found: $DB_DIR"
echo ""

# Create results directory
mkdir -p "$RESULTS_DIR"

# Run analysis
echo "🚀 Running $QUERY_SUITE analysis..."
echo "This may take 1-3 minutes..."
echo ""

"$CODEQL_HOME/codeql/codeql" database analyze "$DB_DIR" \
    "$QUERY_SUITE" \
    --format=sarif-latest \
    --output="$RESULTS_DIR/rust-results.sarif" \
    --threads=0 \
    --ram=8192

echo ""
echo "✅ Analysis complete!"
echo ""
echo "📄 Results saved to: $RESULTS_DIR/rust-results.sarif"
echo "📊 File size: $(du -sh "$RESULTS_DIR/rust-results.sarif" | cut -f1)"
echo ""

# Show summary
if command -v jq &> /dev/null; then
    echo "📊 Summary:"
    RESULT_COUNT=$(jq '.runs[0].results | length' "$RESULTS_DIR/rust-results.sarif")
    echo "  Found $RESULT_COUNT issues"
    echo ""
    if [ "$RESULT_COUNT" -gt 0 ]; then
        echo "Top issues:"
        jq -r '.runs[0].results[0:5] | .[] | "  - \(.ruleId): \(.message.text)"' "$RESULTS_DIR/rust-results.sarif" 2>/dev/null || echo "  (error parsing results)"
    fi
else
    echo "💡 Install jq for detailed summary: sudo apt install jq"
fi

echo ""
echo "View results:"
echo "  1. In VS Code: code $RESULTS_DIR/rust-results.sarif"
echo "  2. With jq: cat $RESULTS_DIR/rust-results.sarif | jq"
echo "  3. Raw JSON: cat $RESULTS_DIR/rust-results.sarif"
echo ""
echo "Next steps:"
echo "  - Review findings in VS Code"
echo "  - Fix identified issues"
echo "  - Re-run analysis to verify fixes"
