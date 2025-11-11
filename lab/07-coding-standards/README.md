# 📏 Lab 07: MISRA & CERT Coding Standards

## 📖 Overview

This lab provides hands-on experience with coding standards compliance
using CodeQL. You'll learn how to run MISRA and CERT compliance
checks, interpret results, and generate compliance reports.

## 🎯 Learning Objectives

By completing this lab, you will:

- ✓ Run MISRA C++:2008 compliance checks
- ✓ Run CERT C/C++ secure coding checks
- ✓ Interpret compliance violations by obligation level
- ✓ Generate compliance reports and matrices
- ✓ Filter violations by category and severity
- ✓ Document rule deviations
- ✓ Create custom compliance query suites

## ✅ Prerequisites

Before starting, ensure you have:

1. **Completed previous labs**:
   - Lab 03: Installation & Configuration
   - Lab 05: C++ and CMake Setup

2. **C++ database created**:
   ```bash
   ls -la ../05-cpp-cmake-setup/databases/test-cpp-db
   ```

3. **CodeQL query packs downloaded**:
   ```bash
   codeql pack download codeql/cpp-queries
   ```

## 📁 Lab Structure

```text
lab/07-coding-standards/
├── README.md                       # This file
├── QUICK-REFERENCE.md             # Quick command reference
├── quick-start.sh                 # Interactive getting started
├── run-misra-checks.sh            # Run MISRA compliance
├── run-cert-checks.sh             # Run CERT compliance
├── generate-report.sh             # Generate compliance reports
├── filter-by-obligation.sh        # Filter by MISRA obligation
├── create-compliance-suite.sh     # Create custom suites
├── compliance-suites/             # Custom query suites
│   ├── misra-required.qls        # Required rules only
│   ├── misra-advisory.qls        # Advisory rules only
│   └── cert-security.qls         # CERT security focus
├── results/                       # Output directory
│   ├── misra-results.sarif
│   ├── cert-results.sarif
│   └── compliance-report.txt
└── test-projects/                 # Sample projects
    └── (using existing ../05-cpp-cmake-setup/test-cpp-project)
```

## 🚀 Exercise 1: Run MISRA Compliance Checks

Learn to run and interpret MISRA C++:2008 compliance checks.

### Step 1: Quick Start

```bash
cd lab/07-coding-standards
./quick-start.sh
```

Select option 1 to run MISRA checks on the test project.

### Step 2: Manual MISRA Check

```bash
./run-misra-checks.sh
```

This script will:
- Run MISRA compliance checks on the C++ test project
- Generate SARIF output with all MISRA violations
- Create a summary report

**Expected output:**

```text
🔍 Running MISRA C++:2008 Compliance Checks...

Analyzing ../05-cpp-cmake-setup/databases/test-cpp-db
Query suite: compliance-suites/misra-all.qls

✓ Analysis complete

📊 MISRA Compliance Summary:
  Total violations: 25
  Required rules:   18 violations
  Advisory rules:   7 violations
  
High-priority violations found!
```

### Step 3: View Results

```bash
# Count violations by obligation
jq '.runs[0].results | 
    group_by(.rule.properties.tags | 
    map(select(startswith("external/misra/obligation"))) | .[0]) | 
    map({obligation: .[0].rule.properties.tags | 
    map(select(startswith("external/misra/obligation"))) | .[0],
    count: length})' \
    results/misra-results.sarif
```

### Step 4: Filter by Obligation Level

```bash
# Required rules only (critical)
./filter-by-obligation.sh results/misra-results.sarif required

# Advisory rules only
./filter-by-obligation.sh results/misra-results.sarif advisory
```

## 🔒 Exercise 2: Run CERT Compliance Checks

Learn to run and interpret CERT C/C++ secure coding checks.

### Step 1: Run CERT Checks

```bash
./run-cert-checks.sh
```

This script will:
- Run CERT compliance checks on the C++ test project
- Generate SARIF output with all CERT violations
- Create a summary report

**Expected output:**

```text
🔒 Running CERT C/C++ Secure Coding Checks...

Analyzing ../05-cpp-cmake-setup/databases/test-cpp-db
Query suite: compliance-suites/cert-all.qls

✓ Analysis complete

📊 CERT Compliance Summary:
  Total violations: 15
  By category:
    ARR (Arrays):          3
    MEM (Memory):          5
    STR (Strings):         2
    ERR (Error handling):  3
    EXP (Expressions):     2
```

### Step 2: View Violations by Category

```bash
# List all violations grouped by category
jq -r '.runs[0].results | 
    map(.ruleId | match("cert/([a-z]+)[0-9]+-") | 
    .captures[0].string) | 
    group_by(.) | 
    map("\(.[0]): \(length) violations") | 
    sort | .[]' \
    results/cert-results.sarif
```

### Step 3: Focus on Specific Categories

```bash
# Memory management violations
jq '.runs[0].results |= 
    map(select(.ruleId | test("cert/mem")))' \
    results/cert-results.sarif \
    > results/cert-mem-only.sarif

# Array violations
jq '.runs[0].results |= 
    map(select(.ruleId | test("cert/arr")))' \
    results/cert-results.sarif \
    > results/cert-arr-only.sarif
```

## 📊 Exercise 3: Generate Compliance Reports

Create comprehensive compliance reports for documentation and audits.

### Step 1: Generate Full Report

```bash
./generate-report.sh results/
```

This creates:
- Text summary report
- CSV export for tracking
- Compliance matrix
- Detailed violation breakdown

**Sample output:**

```text
📊 Coding Standards Compliance Report
=====================================
Generated: 2024-11-11 14:30:00

MISRA C++:2008 Compliance
--------------------------
Total Violations: 25
  Required:       18 (Priority: CRITICAL)
  Advisory:       7  (Priority: Review)

Top Violations:
  1. Rule 5-0-1: Expression value consistency (5 occurrences)
  2. Rule 6-4-1: If-else termination (4 occurrences)
  3. Rule 8-5-1: Visible declarations (3 occurrences)

CERT C/C++ Compliance
---------------------
Total Violations: 15

By Category:
  ARR (Arrays):         3 violations
  MEM (Memory):         5 violations
  STR (Strings):        2 violations
  ERR (Error Handling): 3 violations
  EXP (Expressions):    2 violations

Critical Issues:
  - ARR30-C: Array bounds checking (3 instances)
  - MEM50-CPP: Memory deallocation (2 instances)
  - STR50-CPP: String null termination (2 instances)
```

### Step 2: Export to CSV

```bash
# MISRA violations to CSV
jq -r '.runs[0].results[] | 
    [
        .ruleId,
        (.rule.properties.tags | 
        map(select(startswith("external/misra/obligation"))) | 
        .[0] // "N/A"),
        .message.text,
        .locations[0].physicalLocation.artifactLocation.uri,
        .locations[0].physicalLocation.region.startLine
    ] | @csv' \
    results/misra-results.sarif \
    > results/misra-violations.csv
```

### Step 3: Create Compliance Matrix

```bash
# Shows which rules were checked and violation counts
./generate-report.sh results/ --matrix
```

This generates a matrix showing:
- Rule ID
- Automated/Manual check
- Violation count
- Files affected
- Compliance status

## 🎯 Exercise 4: Create Custom Compliance Suites

Build custom query suites for specific compliance needs.

### Step 1: Interactive Suite Creator

```bash
./create-compliance-suite.sh
```

**Menu options:**
1. MISRA required rules only
2. MISRA advisory rules only
3. CERT security-critical rules
4. Combined MISRA+CERT critical
5. Custom configuration

### Step 2: MISRA Required Rules Only

Pre-made suite in `compliance-suites/misra-required.qls`:

```yaml
# MISRA Required Rules Only
- description: "MISRA C++:2008 Required Rules (Critical)"
- queries: .
- from: codeql/cpp-queries
- include:
    tags:
      - external/misra/obligation/required
    precision:
      - very-high
      - high
- exclude:
    tags:
      - experimental
```

Run it:

```bash
codeql database analyze \
    ../05-cpp-cmake-setup/databases/test-cpp-db \
    compliance-suites/misra-required.qls \
    --format=sarif-latest \
    --output=results/misra-required-only.sarif
```

### Step 3: CERT Security-Critical Rules

Pre-made suite in `compliance-suites/cert-security.qls`:

```yaml
# CERT Security-Critical Rules
- description: "CERT C/C++ Security-Critical Rules"
- queries: .
- from: codeql/cpp-queries
- include:
    tags:
      - external/cert/c/rule
      - external/cert/c++/rule
      - security
    precision:
      - very-high
      - high
- exclude:
    tags:
      - experimental
```

Run it:

```bash
codeql database analyze \
    ../05-cpp-cmake-setup/databases/test-cpp-db \
    compliance-suites/cert-security.qls \
    --format=sarif-latest \
    --output=results/cert-security-only.sarif
```

## 📝 Exercise 5: Document Rule Deviations

Learn to properly document and track rule deviations.

### Step 1: Create Deviation Document

Create `.codeql/deviations.yml`:

```yaml
deviations:
  - rule: "misra-5-0-1"
    file: "src/vulnerable.cpp"
    line: 15
    justification: "Legacy code - scheduled for refactoring"
    approved_by: "Tech Lead"
    approval_date: "2024-01-15"
    review_date: "2024-06-15"
    
  - rule: "cert/arr30-c"
    file: "src/vulnerable.cpp"
    line: 42
    justification: "Array size validated by caller contract"
    approved_by: "Security Team"
    approval_date: "2024-01-20"
    review_date: "2024-07-20"
```

### Step 2: Filter Suppressed Violations

```bash
# List violations that have documented deviations
./check-deviations.sh results/misra-results.sarif .codeql/deviations.yml
```

### Step 3: Track Deviation Status

```bash
# Generate deviation tracking report
./generate-deviation-report.sh .codeql/deviations.yml
```

Output shows:
- Active deviations
- Deviations due for review
- Approval status
- Remediation plans

## 🔄 Exercise 6: Continuous Compliance Monitoring

Set up ongoing compliance tracking.

### Step 1: Establish Baseline

```bash
# Create compliance baseline
cp results/misra-results.sarif baselines/misra-baseline-$(date +%Y%m%d).sarif
cp results/cert-results.sarif baselines/cert-baseline-$(date +%Y%m%d).sarif
```

### Step 2: Track Changes Over Time

```bash
# Compare current vs baseline
jq --slurpfile baseline baselines/misra-baseline-*.sarif \
   '[.runs[0].results[].ruleId] - [$baseline[0].runs[0].results[].ruleId] | 
    unique | length' \
   results/misra-results.sarif
```

### Step 3: Set Up CI/CD Check

Example script for CI/CD (`check-compliance-ci.sh`):

```bash
#!/bin/bash
set -e

# Run compliance checks
./run-misra-checks.sh
./run-cert-checks.sh

# Check for required rule violations
MISRA_REQUIRED=$(jq '[.runs[0].results[] | 
    select(.rule.properties.tags | 
    contains(["external/misra/obligation/required"]))] | length' \
    results/misra-results.sarif)

if [ "$MISRA_REQUIRED" -gt 0 ]; then
    echo "❌ FAILED: $MISRA_REQUIRED MISRA required rule violations"
    exit 1
fi

# Check for CERT critical violations
CERT_CRITICAL=$(jq '[.runs[0].results[] | 
    select(.level == "error")] | length' \
    results/cert-results.sarif)

if [ "$CERT_CRITICAL" -gt 0 ]; then
    echo "❌ FAILED: $CERT_CRITICAL CERT critical violations"
    exit 1
fi

echo "✅ PASSED: No critical compliance violations"
```

## 💡 Exercise 7: Compliance Dashboard

Create a compliance dashboard for ongoing monitoring.

### Step 1: Generate Dashboard Data

```bash
# Create JSON data for dashboard
./generate-dashboard-data.sh > dashboard/compliance-data.json
```

### Step 2: View Compliance Trends

```bash
# Show compliance trend over last 30 days
./show-compliance-trend.sh baselines/ 30
```

**Sample output:**

```text
Compliance Trend (Last 30 Days)
================================

MISRA Required Violations:
  2024-10-15: 25
  2024-10-22: 22 (-3) ↓
  2024-10-29: 20 (-2) ↓
  2024-11-05: 18 (-2) ↓
  2024-11-11: 18 (0) →

CERT Violations:
  2024-10-15: 20
  2024-10-22: 18 (-2) ↓
  2024-10-29: 16 (-2) ↓
  2024-11-05: 15 (-1) ↓
  2024-11-11: 15 (0) →

Trend: Improving ✅
Target: <10 violations by 2024-12-01
```

## 📋 Expected Results

### MISRA Violations in Test Project

The test C++ project should trigger these MISRA rules:

- **Rule 5-0-1**: Expression value consistency
- **Rule 6-4-1**: If-else termination
- **Rule 8-5-1**: Visible identifier declarations
- **Rule 15-3-1**: Exception specifications

### CERT Violations in Test Project

The test C++ project should trigger these CERT rules:

- **ARR30-C**: Array bounds checking
- **MEM50-CPP**: Memory deallocation errors
- **STR50-CPP**: String null termination
- **ERR50-CPP**: Error handling

## ✅ Verification

Check your work:

```bash
# Should have MISRA results
ls -lh results/misra-results.sarif

# Should have CERT results
ls -lh results/cert-results.sarif

# Should have compliance report
ls -lh results/compliance-report.txt

# Should have custom suites
ls compliance-suites/*.qls
```

## 🎓 Key Takeaways

After completing this lab, you should understand:

1. **Standards Purpose**: Why MISRA and CERT exist
   - Safety-critical systems require MISRA
   - Security-critical systems require CERT
   - Compliance reduces risk

2. **Compliance Checking**: How to run checks
   - Different suites for different standards
   - Filtering by obligation/category
   - Interpreting results

3. **Reporting**: How to document compliance
   - Violation tracking
   - Deviation documentation
   - Trend analysis

4. **Integration**: How to maintain compliance
   - CI/CD integration
   - Baseline management
   - Continuous monitoring

## 🚨 Common Issues

**No MISRA/CERT queries found?**
```bash
# Check if query pack is downloaded
codeql pack download codeql/cpp-queries

# Verify queries exist
find ~/.codeql-home/codeql-repo -name "*misra*" -o -name "*cert*"
```

**Too many violations?**
```bash
# Start with required/critical only
./run-misra-checks.sh --required-only
./run-cert-checks.sh --critical-only
```

**Need to suppress false positives?**
```bash
# Document in deviations.yml
# Then filter results
./filter-deviations.sh results/misra-results.sarif
```

## 📚 Additional Resources

- [MISRA C++:2008 Guidelines](https://www.misra.org.uk/)
- [CERT C/C++ Coding Standards](https://wiki.sei.cmu.edu/confluence/display/c)
- [CodeQL Standard Libraries](https://codeql.github.com/codeql-standard-libraries/cpp/)

## ⏭️ Next Steps

1. Complete all lab exercises
2. Apply to your own projects
3. Set up CI/CD compliance checks
4. Continue to Lab 08: SARIF Output Format

---

*💡 Pro Tip: Start with required/critical rules only, achieve
compliance, then gradually add advisory rules. Document all deviations
with clear justifications and review dates.*
