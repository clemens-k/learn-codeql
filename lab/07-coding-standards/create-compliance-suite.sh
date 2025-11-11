#!/bin/bash
# create-compliance-suite.sh - Create custom compliance query suite

set -e

echo "Custom Query Suite Generator"
echo "============================="
echo ""

read -p "Suite name: " SUITE_NAME
read -p "Description: " DESCRIPTION

FILENAME="compliance-suites/${SUITE_NAME}.qls"

if [ -f "$FILENAME" ]; then
    echo "Error: File already exists: $FILENAME"
    exit 1
fi

cat > "$FILENAME" << EOF
---
# $DESCRIPTION

- description: $DESCRIPTION
- qlpack: codeql/cpp-queries
- queries: .
  from: codeql/cpp-queries
EOF

echo ""
echo "Select what to include:"
echo "1. MISRA required rules"
echo "2. MISRA advisory rules"
echo "3. CERT rules"
echo "4. Security queries"
echo "5. Custom tags (manual entry)"
echo ""
read -p "Select (comma-separated, e.g., 1,4): " SELECTION

echo "- include:" >> "$FILENAME"

if [[ $SELECTION == *"1"* ]]; then
    echo "    tags contain:" >> "$FILENAME"
    echo "      - external/misra/obligation/required" >> "$FILENAME"
fi

if [[ $SELECTION == *"2"* ]]; then
    echo "    tags contain:" >> "$FILENAME"
    echo "      - external/misra/obligation/advisory" >> "$FILENAME"
fi

if [[ $SELECTION == *"3"* ]]; then
    echo "    tags contain:" >> "$FILENAME"
    echo "      - external/cert" >> "$FILENAME"
fi

if [[ $SELECTION == *"4"* ]]; then
    echo "    tags contain:" >> "$FILENAME"
    echo "      - security" >> "$FILENAME"
fi

if [[ $SELECTION == *"5"* ]]; then
    echo ""
    read -p "Enter custom tags (comma-separated): " CUSTOM_TAGS
    echo "    tags contain:" >> "$FILENAME"
    IFS=',' read -ra TAGS <<< "$CUSTOM_TAGS"
    for tag in "${TAGS[@]}"; do
        echo "      - $(echo $tag | xargs)" >> "$FILENAME"
    done
fi

echo ""
echo "✅ Created: $FILENAME"
echo ""
echo "Preview:"
cat "$FILENAME"
echo ""
echo "To use this suite:"
echo "  codeql database analyze <db> $FILENAME --format=sarif-latest --output=results.sarif"
