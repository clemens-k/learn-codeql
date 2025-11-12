#!/bin/bash
# Create CodeQL database for Rust test project

set -e

CODEQL_HOME="${CODEQL_HOME:-$HOME/.codeql-home}"
PROJECT_DIR="$(pwd)/test-rust-project"
DB_DIR="$(pwd)/databases/test-rust-db"

echo "🦀 Creating CodeQL Database for Rust Test Project"
echo "=================================================="
echo ""

# Check prerequisites
if [ ! -f "$CODEQL_HOME/codeql/codeql" ]; then
    echo "❌ CodeQL not found at: $CODEQL_HOME/codeql/codeql"
    echo "💡 Run ../03-installation/install-codeql.sh first"
    echo "💡 Or set CODEQL_HOME environment variable"
    exit 1
fi

# Check Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "❌ Cargo not found. Please install Rust toolchain:"
    echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

echo "✓ CodeQL found: $CODEQL_HOME/codeql/codeql"
echo "✓ Rust version: $(rustc --version)"
echo ""

# Build the project first to check it works
echo "📦 Building Rust project..."
cd "$PROJECT_DIR"
cargo build
cd ..

echo "✓ Project built successfully"
echo ""

# Create database directory
mkdir -p databases

# Remove old database if exists
if [ -d "$DB_DIR" ]; then
    echo "🗑️  Removing old database..."
    rm -rf "$DB_DIR"
fi

# Create CodeQL database
echo "🔍 Creating CodeQL database..."
echo "This may take a minute..."
echo ""

"$CODEQL_HOME/codeql/codeql" database create "$DB_DIR" \
    --language=rust \
    --source-root="$PROJECT_DIR"

echo ""
echo "✅ Database created: $DB_DIR"
echo "📊 Database size: $(du -sh "$DB_DIR" | cut -f1)"
echo ""
echo "Next: Run ./analyze-rust-database.sh to analyze"
