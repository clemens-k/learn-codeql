#!/bin/bash
# quick-start.sh - Quick start script for Lab 06

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 Lab 06 Quick Start${NC}"
echo "===================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v codeql &> /dev/null; then
    echo "❌ CodeQL CLI not found. Please complete Lab 03 first."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Installing..."
    sudo apt-get update && sudo apt-get install -y jq
fi

# Check for databases
CPP_DB="../05-cpp-cmake-setup/databases/test-cpp-db"
RUST_DB="../04-rust-setup/databases/test-rust-db"

if [ ! -d "$CPP_DB" ] && [ ! -d "$RUST_DB" ]; then
    echo "❌ No databases found!"
    echo ""
    echo "Please run one of the following first:"
    echo "  cd ../04-rust-setup && ./create-rust-database.sh"
    echo "  cd ../05-cpp-cmake-setup && ./create-cpp-database.sh"
    exit 1
fi

echo "✅ Prerequisites OK"
echo ""

# Menu
echo -e "${BLUE}What would you like to do?${NC}"
echo ""
echo "1. Run all query suites (takes 30-60 minutes)"
echo "2. Run just code-scanning suite (fast, ~5 minutes)"
echo "3. Compare existing results"
echo "4. Create custom query suite"
echo "5. View help"
echo ""
read -p "Select option (1-5): " choice

case $choice in
    1)
        echo ""
        echo "Running all suites. This will take a while..."
        ./run-all-suites.sh
        echo ""
        echo -e "${GREEN}Complete! Now run ./compare-suites.sh${NC}"
        ;;
    2)
        echo ""
        echo "Running code-scanning suite (fast)..."
        mkdir -p results
        
        if [ -d "$CPP_DB" ]; then
            echo "Analyzing C++..."
            codeql database analyze "$CPP_DB" \
                codeql/cpp-queries:codeql-suites/cpp-code-scanning.qls \
                --format=sarif-latest \
                --output=results/cpp-code-scanning.sarif
        fi
        
        if [ -d "$RUST_DB" ]; then
            echo "Analyzing Rust..."
            codeql database analyze "$RUST_DB" \
                codeql/rust-queries:codeql-suites/rust-code-scanning.qls \
                --format=sarif-latest \
                --output=results/rust-code-scanning.sarif
        fi
        
        echo ""
        echo -e "${GREEN}Complete! Results in results/${NC}"
        ;;
    3)
        if [ -d "results" ] && [ -n "$(ls -A results/*.sarif 2>/dev/null)" ]; then
            ./compare-suites.sh
        else
            echo "No results found. Run option 1 or 2 first."
        fi
        ;;
    4)
        ./create-custom-suite.sh
        ;;
    5)
        echo ""
        cat README.md
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo "  • Analyze results: ./analyze-by-severity.sh results/<file>.sarif"
echo "  • Filter results: ./filter-results.sh results/<file>.sarif"
echo "  • Compare suites: ./compare-suites.sh"
echo "  • Read full guide: cat README.md"
