#!/bin/bash
# Create CodeQL database for Rust test project

set -e

CODEQL_HOME="$HOME/.codeql-home"
PROJECT_DIR="$(pwd)/test-rust-project"
DB_DIR="$(pwd)/databases/test-rust-db"

echo "🦀 Creating CodeQL Database for Rust Test Project"
echo "=================================================="
echo ""

# Check prerequisites
if [ ! -f "$CODEQL_HOME/codeql/codeql" ]; then
    echo "❌ CodeQL not found. Run ./install-codeql.sh first"
    exit 1
fi

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

codeql database create "$DB_DIR" \
    --language=rust \
    --source-root="$PROJECT_DIR"

echo ""
echo "✅ Database created: $DB_DIR"
echo ""
echo "📊 Database info:"
codeql database info "$DB_DIR"
echo ""
echo "Next: Run ./analyze-rust-database.sh to analyze"
