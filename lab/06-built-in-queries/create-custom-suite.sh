#!/bin/bash
# create-custom-suite.sh - Generate custom query suite configurations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUSTOM_DIR="$SCRIPT_DIR/custom-suites"

mkdir -p "$CUSTOM_DIR"

echo -e "${CYAN}Create Custom Query Suite${NC}"
echo "========================="
echo ""
echo "Available templates:"
echo "  1. High severity security only (>= 8.0)"
echo "  2. Critical security issues (>= 9.0)"
echo "  3. Code quality focus"
echo "  4. Memory safety focus (C++)"
echo "  5. Error handling focus (Rust)"
echo "  6. Custom configuration"
echo ""
read -p "Select template (1-6): " choice

case $choice in
    1)
        echo -e "${BLUE}Creating high severity security suite...${NC}"
        cat > "$CUSTOM_DIR/high-severity-security.qls" << 'EOF'
# High Severity Security Issues (>= 8.0)
# For production security audits

- description: "High severity security issues only"
- queries: .
- from:
    - codeql/cpp-queries
    - codeql/rust-queries
- include:
    tags:
      - security
    precision:
      - very-high
      - high
- exclude:
    tags:
      - experimental
    query path:
      - "**/test/**"
      - "**/tests/**"
EOF
        echo -e "${GREEN}✓ Created: $CUSTOM_DIR/high-severity-security.qls${NC}"
        ;;
        
    2)
        echo -e "${BLUE}Creating critical security suite...${NC}"
        cat > "$CUSTOM_DIR/critical-security.qls" << 'EOF'
# Critical Security Issues (>= 9.0)
# For emergency security reviews

- description: "Critical security vulnerabilities only"
- queries: .
- from:
    - codeql/cpp-queries
    - codeql/rust-queries
- include:
    tags:
      - security
    precision:
      - very-high
    query path:
      - "**/Security/**"
- exclude:
    tags:
      - experimental
EOF
        echo -e "${GREEN}✓ Created: $CUSTOM_DIR/critical-security.qls${NC}"
        ;;
        
    3)
        echo -e "${BLUE}Creating code quality suite...${NC}"
        cat > "$CUSTOM_DIR/code-quality.qls" << 'EOF'
# Code Quality Focus
# For maintainability and best practices

- description: "Code quality and maintainability"
- queries: .
- from:
    - codeql/cpp-queries
    - codeql/rust-queries
- include:
    tags:
      - correctness
      - maintainability
    precision:
      - very-high
      - high
- exclude:
    tags:
      - security
      - experimental
EOF
        echo -e "${GREEN}✓ Created: $CUSTOM_DIR/code-quality.qls${NC}"
        ;;
        
    4)
        echo -e "${BLUE}Creating C++ memory safety suite...${NC}"
        cat > "$CUSTOM_DIR/cpp-memory-safety.qls" << 'EOF'
# C++ Memory Safety Focus
# Buffer overflows, use-after-free, memory leaks

- description: "C++ memory safety issues"
- queries: .
- from: codeql/cpp-queries
- include:
    tags:
      - security
    query path:
      - "**/Security/CWE/CWE-119/**"  # Buffer overflow
      - "**/Security/CWE/CWE-120/**"  # Buffer copy
      - "**/Security/CWE/CWE-401/**"  # Memory leak
      - "**/Security/CWE/CWE-415/**"  # Double free
      - "**/Security/CWE/CWE-416/**"  # Use after free
      - "**/Security/CWE/CWE-476/**"  # Null dereference
      - "**/Security/CWE/CWE-787/**"  # Out-of-bounds write
    precision:
      - very-high
      - high
EOF
        echo -e "${GREEN}✓ Created: $CUSTOM_DIR/cpp-memory-safety.qls${NC}"
        ;;
        
    5)
        echo -e "${BLUE}Creating Rust error handling suite...${NC}"
        cat > "$CUSTOM_DIR/rust-error-handling.qls" << 'EOF'
# Rust Error Handling Focus
# Unwrap abuse, panic usage, Result handling

- description: "Rust error handling issues"
- queries: .
- from: codeql/rust-queries
- include:
    tags:
      - correctness
      - security
    query path:
      - "**/*unwrap*"
      - "**/*panic*"
      - "**/*result*"
      - "**/*option*"
    precision:
      - very-high
      - high
- exclude:
    tags:
      - experimental
    query path:
      - "**/test/**"
EOF
        echo -e "${GREEN}✓ Created: $CUSTOM_DIR/rust-error-handling.qls${NC}"
        ;;
        
    6)
        echo -e "${BLUE}Creating custom configuration...${NC}"
        echo ""
        read -p "Enter suite name: " suite_name
        read -p "Enter description: " description
        
        echo "Select language:"
        echo "  1. C++"
        echo "  2. Rust"
        echo "  3. Both"
        read -p "Choice: " lang_choice
        
        case $lang_choice in
            1) from="codeql/cpp-queries" ;;
            2) from="codeql/rust-queries" ;;
            3) from="codeql/cpp-queries
    - codeql/rust-queries" ;;
            *) from="codeql/cpp-queries" ;;
        esac
        
        echo ""
        echo "Select focus:"
        echo "  1. Security only"
        echo "  2. Quality only"
        echo "  3. Both"
        read -p "Choice: " focus_choice
        
        case $focus_choice in
            1) tags="- security" ;;
            2) tags="- correctness
      - maintainability" ;;
            3) tags="- security
      - correctness" ;;
            *) tags="- security" ;;
        esac
        
        FILENAME="$CUSTOM_DIR/${suite_name// /-}.qls"
        cat > "$FILENAME" << EOF
# $suite_name
# $description

- description: "$description"
- queries: .
- from:
    - $from
- include:
    tags:
      $tags
    precision:
      - very-high
      - high
- exclude:
    tags:
      - experimental
EOF
        echo -e "${GREEN}✓ Created: $FILENAME${NC}"
        ;;
        
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}Usage:${NC}"
echo ""
echo "C++:"
echo "  codeql database analyze \\"
echo "    ../05-cpp-cmake-setup/databases/test-cpp-db \\"
echo "    $CUSTOM_DIR/$(ls -t "$CUSTOM_DIR" | head -1) \\"
echo "    --format=sarif-latest \\"
echo "    --output=results/custom-cpp-results.sarif"
echo ""
echo "Rust:"
echo "  codeql database analyze \\"
echo "    ../04-rust-setup/databases/test-rust-db \\"
echo "    $CUSTOM_DIR/$(ls -t "$CUSTOM_DIR" | head -1) \\"
echo "    --format=sarif-latest \\"
echo "    --output=results/custom-rust-results.sarif"
