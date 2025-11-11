#!/bin/bash
# Create CodeQL database for C++ test project

set -e

CODEQL_HOME="$HOME/.codeql-home"
PROJECT_DIR="$(pwd)/test-cpp-project"
DB_DIR="$(pwd)/databases/test-cpp-db"

echo "🔨 Creating CodeQL Database for C++ Test Project"
echo "================================================="
echo ""

# Check prerequisites
if [ ! -f "$CODEQL_HOME/codeql/codeql" ]; then
    echo "❌ CodeQL not found. Run ./install-codeql.sh first"
    exit 1
fi

# Build the project first
echo "📦 Configuring C++ project..."
pushd "$PROJECT_DIR"
mkdir -p build
pushd build
cmake .. -G Ninja --fresh
popd
popd
echo "✓ Project configured successfully"
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
    --language=cpp \
    --source-root="$PROJECT_DIR" \
    --command="ninja -C $PROJECT_DIR/build"

echo ""
echo "✅ Database created: $DB_DIR"
echo ""
echo "Next: Run ./analyze-cpp-database.sh to analyze"
