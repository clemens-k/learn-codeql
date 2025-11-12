#!/bin/bash
# quick-start.sh - Quick start for Lab 07

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 Lab 07 Quick Start${NC}"
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

CPP_DB="../05-cpp-cmake-setup/databases/test-cpp-db"

if [ ! -d "$CPP_DB" ]; then
    echo "❌ No C++ database found!"
    echo ""
    echo "Please run Lab 05 first:"
    echo "  cd ../05-cpp-cmake-setup && ./create-cpp-database.sh"
    exit 1
fi

echo "✅ Prerequisites OK"
echo ""

# Menu
echo -e "${BLUE}What would you like to do?${NC}"
echo ""
echo "1. Run MISRA compliance checks"
echo "2. Run CERT compliance checks"
echo "3. Run both MISRA and CERT"
echo "4. Generate compliance report"
echo "5. View help"
echo ""
read -p "Select option (1-5): " choice

case $choice in
    1)
        echo ""
        ./run-misra-checks.sh
        ;;
    2)
        echo ""
        ./run-cert-checks.sh
        ;;
    3)
        echo ""
        ./run-misra-checks.sh
        echo ""
        ./run-cert-checks.sh
        ;;
    4)
        if [ -d "results" ] && [ -n "$(ls -A results/*.sarif 2>/dev/null)" ]; then
            ./generate-report.sh results/
        else
            echo "No results found. Run option 1, 2, or 3 first."
        fi
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
echo "  • Filter by obligation: ./filter-by-obligation.sh results/misra-results.sarif required"
echo "  • Generate report: ./generate-report.sh results/"
echo "  • Read full guide: cat README.md"
