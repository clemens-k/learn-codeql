#!/bin/bash
# quick-start.sh - Interactive menu for Lab 08

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 Lab 08 Quick Start: SARIF Output Processing${NC}"
echo "================================================"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Installing..."
    sudo apt-get update && sudo apt-get install -y jq
fi

if ! command -v codeql &> /dev/null; then
    echo "❌ CodeQL CLI not found. Please complete Lab 03 first."
    exit 1
fi

echo "✅ Prerequisites OK"
echo ""

# Menu
echo -e "${BLUE}What would you like to do?${NC}"
echo ""
echo "1. Generate sample SARIF files"
echo "2. Analyze existing SARIF file"
echo "3. Filter SARIF results"
echo "4. Create baseline"
echo "5. Compare two scans"
echo "6. Generate report"
echo "7. Extract metrics"
echo "8. Merge SARIF files"
echo "9. View help"
echo ""
read -p "Select option (1-9): " choice

case $choice in
    1)
        echo ""
        ./generate-sarif.sh
        echo ""
        echo "Try: ./analyze-sarif.sh results/security-and-quality-scan.sarif"
        ;;
    2)
        echo ""
        if [ -f "results/security-and-quality-scan.sarif" ]; then
            ./analyze-sarif.sh results/security-and-quality-scan.sarif
        else
            echo "No SARIF files found. Run option 1 first."
        fi
        ;;
    3)
        echo ""
        read -p "Filter by (rule/tag/level/precision/file): " filter_type
        read -p "Filter value: " filter_value
        ./filter-results.sh results/security-and-quality-scan.sarif \
            --$filter_type "$filter_value" \
            --output results/filtered.sarif
        ;;
    4)
        echo ""
        if [ -f "results/security-and-quality-scan.sarif" ]; then
            ./create-baseline.sh results/security-and-quality-scan.sarif
        else
            echo "No SARIF files found. Run option 1 first."
        fi
        ;;
    5)
        echo ""
        echo "Available SARIF files:"
        ls -1 results/*.sarif 2>/dev/null || echo "None"
        echo ""
        read -p "Baseline file: " baseline
        read -p "Current file: " current
        ./compare-scans.sh "$baseline" "$current"
        ;;
    6)
        echo ""
        read -p "Format (summary/html/csv): " format
        ./generate-report.sh results/security-and-quality-scan.sarif \
            --format "$format" \
            --output "reports/report.$format"
        ;;
    7)
        echo ""
        ./extract-metrics.sh results/security-and-quality-scan.sarif \
            --output metrics/current.json
        ;;
    8)
        echo ""
        echo "Available SARIF files:"
        ls -1 results/*.sarif 2>/dev/null || echo "None"
        echo ""
        read -p "File 1: " file1
        read -p "File 2: " file2
        ./merge-sarif.sh "$file1" "$file2" \
            --deduplicate \
            --output results/merged.sarif
        ;;
    9)
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
echo "  • Read full guide: cat README.md"
echo "  • Quick reference: cat QUICK-REFERENCE.md"
echo "  • Run again: ./quick-start.sh"
