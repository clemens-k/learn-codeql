#!/bin/bash
# create-compliance-suite.sh - Create custom compliance query suite

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Custom Query Suite Generator${NC}"
echo "============================="
echo ""
echo "This script will create a custom .qls (query suite) file"
echo "for MISRA/CERT compliance checking."
echo ""

# Ensure directory exists
mkdir -p compliance-suites
echo -e "${GREEN}✓${NC} Created compliance-suites/ directory"
echo ""

read -p "Suite name (e.g., critical-rules): " SUITE_NAME
echo -e "${GREEN}→${NC} Suite name: $SUITE_NAME"

read -p "Description: " DESCRIPTION
echo -e "${GREEN}→${NC} Description: $DESCRIPTION"

FILENAME="compliance-suites/${SUITE_NAME}.qls"

if [ -f "$FILENAME" ]; then
    echo -e "${YELLOW}Error:${NC} File already exists: $FILENAME"
    exit 1
fi

echo ""
echo -e "${BLUE}Creating base suite file...${NC}"

cat > "$FILENAME" << EOF
---
# $DESCRIPTION

- description: $DESCRIPTION
- qlpack: codeql/cpp-queries
- queries: .
  from: codeql/cpp-queries
EOF

echo -e "${GREEN}✓${NC} Created base file: $FILENAME"

echo -e "${GREEN}✓${NC} Created base file: $FILENAME"

echo ""
echo -e "${BLUE}Select what to include:${NC}"
echo "  1. MISRA required rules"
echo "  2. MISRA advisory rules"
echo "  3. CERT rules"
echo "  4. Security queries"
echo "  5. Custom tags (manual entry)"
echo ""
read -p "Select (comma-separated, e.g., 1,4): " SELECTION
echo -e "${GREEN}→${NC} Selection: $SELECTION"

echo ""
echo -e "${BLUE}Adding query filters...${NC}"

echo "- include:" >> "$FILENAME"

if [[ $SELECTION == *"1"* ]]; then
    echo -e "${GREEN}  ✓${NC} Adding MISRA required rules"
    echo "    tags contain:" >> "$FILENAME"
    echo "      - external/misra/obligation/required" >> "$FILENAME"
fi

if [[ $SELECTION == *"2"* ]]; then
    echo -e "${GREEN}  ✓${NC} Adding MISRA advisory rules"
    echo "    tags contain:" >> "$FILENAME"
    echo "      - external/misra/obligation/advisory" >> "$FILENAME"
fi

if [[ $SELECTION == *"3"* ]]; then
    echo -e "${GREEN}  ✓${NC} Adding CERT rules"
    echo "    tags contain:" >> "$FILENAME"
    echo "      - external/cert" >> "$FILENAME"
fi

if [[ $SELECTION == *"4"* ]]; then
    echo -e "${GREEN}  ✓${NC} Adding security queries"
    echo "    tags contain:" >> "$FILENAME"
    echo "      - security" >> "$FILENAME"
fi

if [[ $SELECTION == *"5"* ]]; then
    echo ""
    read -p "Enter custom tags (comma-separated): " CUSTOM_TAGS
    echo -e "${GREEN}  ✓${NC} Adding custom tags: $CUSTOM_TAGS"
    echo "    tags contain:" >> "$FILENAME"
    IFS=',' read -ra TAGS <<< "$CUSTOM_TAGS"
    for tag in "${TAGS[@]}"; do
        tag_clean=$(echo $tag | xargs)
        echo "      - $tag_clean" >> "$FILENAME"
        echo -e "${GREEN}    →${NC} Added tag: $tag_clean"
    done
fi

echo ""
echo -e "${GREEN}✅ Successfully created: $FILENAME${NC}"
echo ""
echo -e "${BLUE}Preview:${NC}"
cat "$FILENAME"
echo ""
echo -e "${YELLOW}To use this suite:${NC}"
echo "  codeql database analyze <db> $FILENAME --format=sarif-latest --output=results.sarif"
