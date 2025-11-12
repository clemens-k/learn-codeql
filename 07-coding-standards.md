# 📏 MISRA & CERT Coding Standards

## 📖 Overview

CodeQL supports compliance checking for major coding standards including
MISRA C/C++ and CERT C/C++. This guide shows you how to use CodeQL to
enforce coding standards, generate compliance reports, and integrate
standards checking into your development workflow.

---

## 🎯 What You'll Learn

- Understanding MISRA and CERT coding standards
- Available CodeQL query packs for standards compliance
- Running compliance checks with CodeQL
- Interpreting and reporting compliance results
- Integrating standards checking into CI/CD
- Best practices for standards enforcement

---

## 📚 Coding Standards Overview

### MISRA (Motor Industry Software Reliability Association)

**Purpose**: Safety-critical software development guidelines

**Versions**:
- **MISRA C:2012** (Amendment 1: 2016, Amendment 2: 2020, Amendment 3: 2024)
- **MISRA C:2023** (latest, expanded coverage and modernization)
- **MISRA C++:2023** (latest, replaces C++:2008, supports modern C++)

**Focus Areas**:
- Memory safety
- Type safety
- Error handling
- Defensive programming
- Predictable behavior

**Common in**: Automotive, aerospace, medical devices, industrial systems

**What's New in MISRA C++:2023**:
- Modern C++ support (C++11, C++14, C++17 features)
- Enhanced memory safety rules
- Improved guidance for templates and smart pointers
- Better undefined behavior coverage
- Clearer automation guidance

### CERT (Computer Emergency Response Team)

**Purpose**: Secure coding practices for production software

**Standards**:
- **CERT C Coding Standard**
- **CERT C++ Coding Standard**
- **SEI CERT Oracle Coding Standard for Java** (not covered here)

**Focus Areas**:
- Security vulnerabilities
- Undefined behavior
- Implementation-defined behavior
- Common programming errors
- Platform-specific issues

**Common in**: Security-critical applications, financial systems

---

## 📦 Available Query Packs

### CodeQL Coding Standards Repository

CodeQL provides dedicated compliance query packs through the official
**GitHub CodeQL Coding Standards** repository:

**Repository**: <https://github.com/github/codeql-coding-standards>

**Installation** (covered in Tutorial 03):
```bash
cd ~/.codeql-home
git clone https://github.com/github/codeql-coding-standards.git \
  coding-standards
```

This repository provides:
- MISRA C:2012 queries
- MISRA C++:2023 queries
- CERT C queries
- CERT C++ queries
- Pre-configured compliance suites
- Standards documentation

### MISRA Query Packs

**Available Packs**:
```bash
# MISRA C:2012
coding-standards/c/misra/src/

# MISRA C++:2023  
coding-standards/cpp/misra/src/
```

**Coverage**:
- MISRA C:2012 - ~200+ rules (150+ automated)
- MISRA C++:2023 - ~250+ rules (170+ automated)
- Automated checks for decidable rules
- Manual review guidance for non-automatable rules

**Rule Categories**:
- **Required**: Must be followed (violations block release)
- **Advisory**: Should be followed (violations need justification)
- **Decidable**: Can be fully automated
- **Undecidable**: Require manual review

**Note**: Full MISRA compliance requires both automated checks and
manual code review. CodeQL automates all decidable rules.

### CERT Query Packs

**Available Packs**:
```bash
# CERT C  
coding-standards/c/cert/src/

# CERT C++
coding-standards/cpp/cert/src/
```

**Coverage**:
- CERT C Coding Standard - ~100+ automated rules
- CERT C++ Coding Standard - ~90+ automated rules
- Focus on security and reliability
- Covers undefined behavior and common vulnerabilities

---

## 🔍 Running Compliance Checks

### MISRA Compliance

#### List Available MISRA Queries

```bash
# Find MISRA C++:2023 queries
find ~/.codeql-home/coding-standards/cpp/misra/src -name "*.ql"

# Find MISRA C:2012 queries
find ~/.codeql-home/coding-standards/c/misra/src -name "*.ql"

# View available query suites
ls ~/.codeql-home/coding-standards/cpp/misra/src/codeql-suites/
```

#### Run MISRA C++:2023 Checks

**Option 1: Use Pre-configured Suite**

```bash
codeql database analyze cpp-db \
    ~/.codeql-home/coding-standards/cpp/misra/src/codeql-suites/misra-cpp-2023.qls \
    --format=sarif-latest \
    --output=misra-results.sarif
```

**Option 2: Custom MISRA Suite**

Create `misra-compliance.qls`:

```yaml
# MISRA C++:2023 Compliance Suite
- description: "MISRA C++:2023 compliance checks"
- queries: .
- from: ~/.codeql-home/coding-standards/cpp/misra/src
- include:
    tags:
      - external/misra/cpp/2023
      - external/misra/obligation/required
      - external/misra/obligation/advisory
- exclude:
    tags:
      - undecidable
```

Run the suite:

```bash
codeql database analyze cpp-db \
    misra-compliance.qls \
    --format=sarif-latest \
    --output=misra-results.sarif \
    --search-path ~/.codeql-home/coding-standards
```

#### MISRA Rule Categories

**Required Rules**: Must be followed (violations are critical)
**Advisory Rules**: Should be followed (violations are warnings)
**Disapplied Rules**: Can be formally disapplied with justification

**Filter by obligation level**:

```bash
# Required rules only
jq '.runs[0].results |= 
    map(select(.rule.properties.tags | 
    contains(["external/misra/obligation/required"])))' \
    misra-results.sarif > misra-required.sarif

# Advisory rules
jq '.runs[0].results |= 
    map(select(.rule.properties.tags | 
    contains(["external/misra/obligation/advisory"])))' \
    misra-results.sarif > misra-advisory.sarif
```

**Filter by decidability**:

```bash
# Decidable (automated) rules only
jq '.runs[0].results |= 
    map(select(.rule.properties.tags | 
    contains(["decidable"]) and 
    (contains(["undecidable"]) | not)))' \
    misra-results.sarif > misra-decidable.sarif
```

### CERT Compliance

#### List Available CERT Queries

```bash
# Find CERT C++ queries
find ~/.codeql-home/coding-standards/cpp/cert/src -name "*.ql"

# Find CERT C queries
find ~/.codeql-home/coding-standards/c/cert/src -name "*.ql"

# View available query suites
ls ~/.codeql-home/coding-standards/cpp/cert/src/codeql-suites/
```

#### Run CERT Checks

**Option 1: Use Pre-configured Suite**

```bash
codeql database analyze cpp-db \
    ~/.codeql-home/coding-standards/cpp/cert/src/codeql-suites/cert-cpp.qls \
    --format=sarif-latest \
    --output=cert-results.sarif
```

**Option 2: Custom CERT Suite**

Create `cert-compliance.qls`:

```yaml
# CERT C/C++ Compliance Suite
- description: "CERT C/C++ secure coding checks"
- queries: .
- from: ~/.codeql-home/coding-standards/cpp/cert/src
- include:
    tags:
      - external/cert/c/rule
      - external/cert/c++/rule
    precision:
      - very-high
      - high
- exclude:
    tags:
      - experimental
```

Run the suite:

```bash
codeql database analyze cpp-db \
    cert-compliance.qls \
    --format=sarif-latest \
    --output=cert-results.sarif \
    --search-path ~/.codeql-home/coding-standards
```

#### CERT Rule Categories

CERT rules are organized by topic:

- **ARR** - Arrays
- **DCL** - Declarations
- **ENV** - Environment
- **ERR** - Error handling
- **EXP** - Expressions
- **FIO** - File I/O
- **INT** - Integers
- **MEM** - Memory management
- **STR** - Strings

**Filter by category**:

```bash
# Memory management rules (MEM)
jq '.runs[0].results |= 
    map(select(.rule.id | test("cpp/cert/mem")))' \
    cert-results.sarif > cert-mem-rules.sarif

# Integer rules (INT)
jq '.runs[0].results |= 
    map(select(.rule.id | test("cpp/cert/int")))' \
    cert-results.sarif > cert-int-rules.sarif
```

---

## 📊 Understanding Compliance Results

### MISRA Results

**Result Format**:

```json
**Result Format**:

```json
{
  "ruleId": "cpp/misra/rule-6-5-1",
  "message": {
    "text": "A for loop shall contain a single loop-counter..."
  },
  "properties": {
    "tags": [
      "external/misra/cpp/2023/rule-6-5-1",
      "external/misra/obligation/required",
      "decidable",
      "correctness"
    ]
  }
}
```

**Rule ID Format**: `cpp/misra/rule-X-Y-Z`
- X = Category number
- Y = Subcategory
- Z = Rule number within subcategory

**Example MISRA C++:2023 Rules**:

| Rule ID | Obligation | Description |
|---------|------------|-------------|
| 6-5-1 | Required | Single loop counter in for loop |
| 8-4-2 | Required | Function parameters shall be identifiable |
| 9-3-1 | Required | const member functions shall not modify object |
| 10-1-1 | Required | Implicit conversions shall not lose information |
| 15-1-2 | Required | NULL pointer shall not be dereferenced |
```

**Rule ID Format**: `cpp/misra/rule-X-Y-Z`
- X = Chapter
- Y = Section
- Z = Rule number

**Example Rules**:

| Rule ID | Obligation | Description |
|---------|------------|-------------|
| 5-0-1 | Required | Expression value consistency |
| 6-4-1 | Required | If-else termination |
| 8-5-1 | Required | Visible identifier declaration |
| 0-1-1 | Required | Standard C++ language features |

### CERT Results

**Result Format**:

```json
{
  "ruleId": "cpp/cert/err50-cpp",
  "message": {
    "text": "Do not abruptly terminate the program"
  },
  "properties": {
    "tags": [
      "external/cert/c++/rule/err50-cpp",
      "security"
    ]
  }
}
```

**Rule ID Format**: `cpp/cert/[category][number]-[c|cpp]`
- category = Rule category (arr, dcl, env, etc.)
- number = Rule number
- c/cpp = C or C++ standard

**Example Rules**:

| Rule ID | Category | Description |
|---------|----------|-------------|
| arr30-c | Arrays | No overflow in array indexing |
| dcl50-cpp | Declarations | No variable-length arrays |
| err50-cpp | Error handling | No abrupt termination |
| mem50-cpp | Memory | No heap deallocation errors |
| str50-cpp | Strings | Null-terminate strings |

---

## 📈 Generating Compliance Reports

### Basic Compliance Summary

```bash
#!/bin/bash
# Generate compliance summary

SARIF_FILE=$1

echo "Compliance Report"
echo "================="
echo ""

# Total violations
echo "Total Violations: $(jq '.runs[0].results | length' $SARIF_FILE)"
echo ""

# By obligation (MISRA)
echo "MISRA by Obligation:"
jq -r '.runs[0].results | 
    group_by(.rule.properties.tags | 
    map(select(startswith("external/misra/obligation"))) | .[0]) | 
    map("\(.[ 0].rule.properties.tags | 
    map(select(startswith("external/misra/obligation"))) | .[0]): \
\(length) violations") | 
    .[]' $SARIF_FILE 2>/dev/null || echo "  No MISRA data"

echo ""

# By category (CERT)
echo "CERT by Category:"
jq -r '.runs[0].results | 
    map(.ruleId | match("cert/([a-z]+)[0-9]+-") | .captures[0].string) | 
    group_by(.) | 
    map("\(.[0]): \(length) violations") | 
    sort | 
    .[]' $SARIF_FILE 2>/dev/null || echo "  No CERT data"
```

### CSV Export for Tracking

```bash
# Export to CSV for spreadsheet tracking
jq -r '.runs[0].results[] | 
    [
        .ruleId,
        .level,
        (.rule.properties.tags | 
        map(select(startswith("external/"))) | .[0] // "N/A"),
        .message.text,
        .locations[0].physicalLocation.artifactLocation.uri,
        .locations[0].physicalLocation.region.startLine
    ] | 
    @csv' \
    misra-results.sarif > misra-violations.csv
```

### HTML Report Generation

Using `sarif-multitool`:

```bash
# Install sarif-multitool
dotnet tool install -g Sarif.Multitool

# Convert to HTML
sarif convert misra-results.sarif \
    --output misra-report.html \
    --output-format html
```

### Compliance Matrix

Generate a compliance matrix showing rule coverage:

```bash
#!/bin/bash
# Generate compliance matrix

echo "Rule ID,Status,Violations,Files Affected" > compliance-matrix.csv

jq -r '.runs[0].tool.driver.rules[] | 
    .id as $rule | 
    ([.id, 
      "automated",
      ($results | map(select(.ruleId == $rule)) | length),
      ($results | map(select(.ruleId == $rule)) | 
       map(.locations[0].physicalLocation.artifactLocation.uri) | 
       unique | length)
    ] | @csv)' \
    --argjson results "$(jq '.runs[0].results' misra-results.sarif)" \
    misra-results.sarif >> compliance-matrix.csv
```

---

## ⚙️ Configuration for Standards

### Project-Level Configuration

Create `.codeql/misra-config.yml`:

```yaml
name: "MISRA Compliance Configuration"

# Disapplied rules (with justification)
disapplied-rules:
  - rule: "5-2-10"
    justification: "Bitwise operations required for hardware interface"
    approved-by: "Tech Lead"
    date: "2024-01-15"
  
  - rule: "7-3-1"
    justification: "Global namespace used for C compatibility"
    approved-by: "Architect"
    date: "2024-01-20"

# Deviation records
deviations:
  - file: "src/legacy/old_code.cpp"
    rules: ["5-0-1", "6-4-1"]
    justification: "Legacy code under migration plan"
    plan: "Refactor by Q2 2024"
```

### Baseline Suppressions

Create a baseline of existing violations:

```bash
# Generate baseline
codeql database analyze cpp-db \
    misra-compliance.qls \
    --format=sarif-latest \
    --output=baseline.sarif

# On subsequent runs, compare
codeql database analyze cpp-db \
    misra-compliance.qls \
    --format=sarif-latest \
    --output=current.sarif

# Find new violations
jq --slurpfile baseline baseline.sarif \
   '.runs[0].results - $baseline[0].runs[0].results' \
   current.sarif > new-violations.sarif
```

---

## 🎯 Best Practices

### 1. Phased Adoption

**Phase 1: Awareness**
- Run compliance checks without enforcement
- Generate reports for visibility
- Identify most common violations

**Phase 2: Prevention**
- Enforce critical rules in CI/CD
- Block builds on required rule violations
- Allow advisory rule violations with review

**Phase 3: Full Compliance**
- Enforce all applicable rules
- Document all deviations
- Regular compliance audits

### 2. Rule Selection

Start with high-impact rules:

**MISRA C++:2023 Priority Rules**:
- 6-5-1: Single loop counter
- 8-4-2: Function parameter identifiability
- 9-3-1: const correctness
- 10-1-1: Safe type conversions
- 15-1-2: NULL pointer checks

**CERT Priority Rules**:
- arr30-c: Array bounds
- err50-cpp: Error handling
- mem50-cpp: Memory safety
- str50-cpp: String safety

### 3. Documentation

Maintain compliance documentation:

```text
project/
├── docs/
│   ├── coding-standards.md        # Standards overview
│   ├── rule-deviations.md         # Documented deviations
│   ├── compliance-plan.md         # Compliance roadmap
│   └── audit-reports/             # Historical reports
└── .codeql/
    ├── misra-config.yml           # MISRA configuration
    ├── cert-config.yml            # CERT configuration
    └── custom-suites/             # Custom query suites
```

### 4. CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Coding Standards Check

on: [push, pull_request]

jobs:
  misra-compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: cpp
      
      - name: Build
        run: cmake -B build && cmake --build build
      
      - name: MISRA Compliance Check
        run: |
          codeql database analyze codeql-db \
            .codeql/misra-compliance.qls \
            --format=sarif-latest \
            --output=misra-results.sarif
      
      - name: Check for Required Rule Violations
        run: |
          VIOLATIONS=$(jq '[.runs[0].results[] | 
            select(.rule.properties.tags | 
            contains(["external/misra/obligation/required"]))] | 
            length' misra-results.sarif)
          
          if [ "$VIOLATIONS" -gt 0 ]; then
            echo "Found $VIOLATIONS required rule violations"
            exit 1
          fi
      
      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: misra-results.sarif
```

### 5. Regular Audits

Schedule regular compliance audits:

```bash
#!/bin/bash
# Monthly compliance audit script

DATE=$(date +%Y-%m)
REPORT_DIR="audit-reports/$DATE"
mkdir -p "$REPORT_DIR"

# Run all compliance checks
codeql database create cpp-db --language=cpp

# MISRA check
codeql database analyze cpp-db misra-compliance.qls \
    --format=sarif-latest \
    --output="$REPORT_DIR/misra-results.sarif"

# CERT check
codeql database analyze cpp-db cert-compliance.qls \
    --format=sarif-latest \
    --output="$REPORT_DIR/cert-results.sarif"

# Generate reports
./generate-compliance-report.sh "$REPORT_DIR"

# Send notification
echo "Monthly compliance audit complete. Results in $REPORT_DIR" | \
    mail -s "Compliance Audit $DATE" team@example.com
```

---

## 🧪 Hands-On Lab Exercise

A complete lab setup is available in `lab/07-coding-standards/`:

### Lab Structure

```text
lab/07-coding-standards/
├── README.md                     # Lab instructions
├── run-misra-checks.sh          # Run MISRA compliance
├── run-cert-checks.sh           # Run CERT compliance
├── generate-report.sh           # Generate compliance reports
├── compliance-suites/           # Custom query suites
│   ├── misra-required.qls
│   ├── misra-advisory.qls
│   └── cert-security.qls
└── test-projects/               # Test projects with violations
    ├── misra-violations/        # MISRA test cases
    └── cert-violations/         # CERT test cases
```

### Running the Lab

```bash
cd lab/07-coding-standards

# Run MISRA checks
./run-misra-checks.sh

# Run CERT checks
./run-cert-checks.sh

# Generate compliance report
./generate-report.sh results/
```

See `lab/07-coding-standards/README.md` for detailed instructions.

---

## 🔍 Common Standard Violations

### MISRA Examples

**Rule 6-5-1: Single Loop Counter**

```cpp
// ❌ Violation (MISRA C++:2023)
for (int i = 0, j = 0; i < 10; i++, j++) {
    // Multiple loop counters
    array[i] = j;
}

// ✅ Compliant
for (int i = 0; i < 10; i++) {
    array[i] = i;
}
```

**Rule 9-3-1: const Correctness**

```cpp
// ❌ Violation
class MyClass {
    int value;
public:
    void getValue() const {
        value = 42;  // Modifying in const function
    }
};

// ✅ Compliant
class MyClass {
    mutable int cache;
    int value;
public:
    void getValue() const {
        cache = value;  // OK: mutable member
    }
    void setValue(int v) {
        value = v;  // Non-const function
    }
};
```

**Rule 10-1-1: Safe Type Conversions**

```cpp
// ❌ Violation
int32_t a = 100000;
int16_t b = a;  // Implicit narrowing conversion

// ✅ Compliant
int32_t a = 100000;
if (a >= INT16_MIN && a <= INT16_MAX) {
    int16_t b = static_cast<int16_t>(a);
}
```

### CERT Examples

**ARR30-C: Array Bounds**

```cpp
// ❌ Violation
int arr[10];
int index = get_index();
arr[index] = 42;  // No bounds check

// ✅ Compliant
int arr[10];
int index = get_index();
if (index >= 0 && index < 10) {
    arr[index] = 42;
}
```

**ERR50-CPP: Error Handling**

```cpp
// ❌ Violation
void critical_function() {
    if (error) {
        std::exit(1);  // Abrupt termination
    }
}

// ✅ Compliant
void critical_function() {
    if (error) {
        throw std::runtime_error("Critical error");
    }
}
```

---

## 📚 Additional Resources

### Official Documentation

- [MISRA Website](https://www.misra.org.uk/)
- [CERT Coding Standards](https://wiki.sei.cmu.edu/confluence/display/c/SEI+CERT+C+Coding+Standard)
- [CodeQL MISRA Support](https://codeql.github.com/codeql-query-help/cpp/)

### Standards Documents

- MISRA C:2012 Guidelines
- MISRA C++:2008 Guidelines
- CERT C Coding Standard
- CERT C++ Coding Standard

### Tools and Extensions

- CodeQL CLI for compliance checking
- SARIF viewers for results analysis
- Static analysis tools integration

---

## ⏭️ Next Steps

Now that you understand coding standards:

1. **Practice**: Work through `lab/07-coding-standards/`
2. **Implement**: Add standards checking to your projects
3. **Learn More**: Continue to `08-sarif-output.md`
4. **Integrate**: Set up CI/CD compliance checks

---

## 🎓 Summary

You've learned:

- ✓ Understanding MISRA and CERT coding standards
- ✓ Available CodeQL query packs for compliance
- ✓ Running compliance checks and interpreting results
- ✓ Generating compliance reports
- ✓ Configuration and customization options
- ✓ Best practices for standards adoption
- ✓ CI/CD integration for continuous compliance

**Key Takeaway**: Coding standards like MISRA and CERT help ensure
safety and security in critical software. CodeQL automates compliance
checking, making it practical to enforce standards throughout the
development lifecycle. Start with high-impact rules, document
deviations, and gradually expand coverage for full compliance.

---

*📝 Note: Full MISRA/CERT compliance requires both automated checks
and manual code reviews. CodeQL handles the automatable portions,
significantly reducing manual review effort.*
