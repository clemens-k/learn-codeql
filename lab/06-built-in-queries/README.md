# 🔍 Lab 06: Using Built-in Query Suites

## 📖 Overview

This lab provides hands-on experience with CodeQL's built-in query
suites. You'll learn how to run different query suites, compare
results, and interpret findings across multiple projects.

## 🎯 Learning Objectives

By completing this lab, you will:

- ✓ Run different query suites (code-scanning, security-and-quality,
  security-extended)
- ✓ Compare results across different suites
- ✓ Filter and analyze SARIF output
- ✓ Understand severity levels and precision ratings
- ✓ Create custom query suite configurations
- ✓ Practice result interpretation and prioritization

## ✅ Prerequisites

Before starting, ensure you have:

1. **Completed previous labs**:
   - Lab 03: Installation & Configuration
   - Lab 04: Rust Setup OR Lab 05: C++ Setup

2. **CodeQL databases created**:
   ```bash
   # Check for existing databases
   ls -la ../04-rust-setup/databases/test-rust-db 2>/dev/null
   ls -la ../05-cpp-cmake-setup/databases/test-cpp-db 2>/dev/null
   ```

3. **CodeQL query packs downloaded**:
   ```bash
   codeql pack download codeql/cpp-queries
   codeql pack download codeql/rust-queries
   ```

## 📁 Lab Structure

```text
lab/06-built-in-queries/
├── README.md                          # This file
├── run-all-suites.sh                  # Run all query suites
├── compare-suites.sh                  # Compare suite results
├── filter-results.sh                  # Filter SARIF by criteria
├── analyze-by-severity.sh             # Group by severity
├── create-custom-suite.sh             # Generate custom suite
├── results/                           # Output directory
│   ├── cpp-code-scanning.sarif
│   ├── cpp-security-and-quality.sarif
│   ├── cpp-security-extended.sarif
│   ├── rust-code-scanning.sarif
│   ├── rust-security-and-quality.sarif
│   ├── rust-security-extended.sarif
│   └── comparison-report.txt
└── custom-suites/                     # Custom query suites
    ├── high-severity-only.qls
    ├── critical-security.qls
    └── code-quality.qls
```

## 🚀 Exercise 1: Run All Query Suites

Compare different query suites on the same codebase.

### Step 1: Run All Suites

```bash
cd lab/06-built-in-queries
./run-all-suites.sh
```

This script will:
- Run code-scanning suite (fast, production-ready)
- Run security-and-quality suite (balanced)
- Run security-extended suite (comprehensive)
- Generate SARIF files for each suite

**Expected output:**

```text
🔍 Running all query suites...

[1/3] Running code-scanning suite...
  C++: 5-10 minutes
  Rust: 3-5 minutes
  ✓ Complete

[2/3] Running security-and-quality suite...
  C++: 15-30 minutes
  Rust: 10-15 minutes
  ✓ Complete

[3/3] Running security-extended suite...
  C++: 30-60 minutes
  Rust: 15-30 minutes
  ✓ Complete

📊 Results saved to results/
```

### Step 2: Quick Result Check

```bash
# Count findings per suite
for file in results/*.sarif; do
    echo "$(basename $file): $(jq '.runs[0].results | length' $file) \
findings"
done
```

**Expected pattern:**
- code-scanning: Fewest results (high precision)
- security-and-quality: More results (balanced)
- security-extended: Most results (comprehensive)

## 🔬 Exercise 2: Compare Query Suites

Analyze differences between suites.

### Step 1: Run Comparison Script

```bash
./compare-suites.sh
```

This generates a detailed comparison report showing:
- Total findings per suite
- Unique findings in each suite
- Common findings across all suites
- Execution time comparison

**Sample output:**

```text
📊 Query Suite Comparison Report
================================

C++ Results:
  code-scanning:          12 findings (100% precision)
  security-and-quality:   28 findings (85% precision)
  security-extended:      45 findings (70% precision)

Rust Results:
  code-scanning:           5 findings (100% precision)
  security-and-quality:   15 findings (90% precision)
  security-extended:      23 findings (75% precision)

Overlap Analysis:
  All 3 suites agree:     8 findings (critical)
  2 suites agree:        12 findings (important)
  Extended only:         25 findings (investigate)
```

### Step 2: Identify Critical Issues

Issues found by all three suites are highest priority:

```bash
# Extract critical issues (found by all suites)
jq -r '.runs[0].results[] | 
    "\(.ruleId): \(.message.text) at \
    \(.locations[0].physicalLocation.artifactLocation.uri):\
    \(.locations[0].physicalLocation.region.startLine)"' \
    results/cpp-code-scanning.sarif
```

## 📊 Exercise 3: Analyze by Severity

Group and analyze results by severity level.

### Step 1: Run Severity Analysis

```bash
./analyze-by-severity.sh results/cpp-security-and-quality.sarif
```

**Output:**

```text
🔴 ERROR (Critical):     8 findings
🟡 WARNING (Important):  15 findings
🔵 NOTE (Info):          5 findings

Top Issues by Security Severity:
  9.8 - Buffer overflow in vulnerable.cpp:15
  9.3 - Use after free in vulnerable.cpp:28
  8.5 - Command injection in vulnerable.cpp:42
  7.2 - Memory leak in vulnerable.cpp:35
```

### Step 2: Filter by Severity

```bash
# Only errors
jq '.runs[0].results |= map(select(.level == "error"))' \
    results/cpp-security-and-quality.sarif \
    > results/errors-only.sarif

# Count by severity
jq '.runs[0].results | group_by(.level) | 
    map({severity: .[0].level, count: length})' \
    results/cpp-security-and-quality.sarif
```

### Step 3: Filter by Security Score

```bash
# High security severity (>= 8.0)
jq '.runs[0].results |= 
    map(select(.rule.properties."security-severity" >= 8.0))' \
    results/cpp-security-and-quality.sarif \
    > results/high-severity.sarif
```

## 🎯 Exercise 4: Filter and Customize Results

Practice filtering results by various criteria.

### Step 1: Run Filter Script

```bash
./filter-results.sh results/cpp-security-and-quality.sarif
```

**Options:**

```text
Filter Results Menu:
1. By severity level (error/warning/note)
2. By precision (very-high/high/medium/low)
3. By security severity score
4. By CWE category
5. By file path
6. Custom filter

Select option:
```

### Step 2: Filter by Precision

```bash
# Very high precision only (lowest false positives)
jq '.runs[0].results |= 
    map(select(.rule.properties.precision == "very-high"))' \
    results/cpp-security-and-quality.sarif \
    > results/very-high-precision.sarif
```

### Step 3: Filter by CWE

```bash
# Buffer overflow issues (CWE-119)
jq '.runs[0].results |= 
    map(select(.rule.properties.tags | 
    contains(["external/cwe/cwe-119"])))' \
    results/cpp-security-and-quality.sarif \
    > results/buffer-overflows.sarif

# Memory management issues (CWE-401, CWE-416)
jq '.runs[0].results |= 
    map(select(.rule.properties.tags | 
    contains(["external/cwe/cwe-401"]) or 
    contains(["external/cwe/cwe-416"])))' \
    results/cpp-security-and-quality.sarif \
    > results/memory-issues.sarif
```

### Step 4: Filter by File Path

```bash
# Only src/ directory
jq '.runs[0].results |= 
    map(select(.locations[0].physicalLocation.artifactLocation.uri 
    | startswith("src/")))' \
    results/cpp-security-and-quality.sarif \
    > results/src-only.sarif
```

## 🛠️ Exercise 5: Create Custom Query Suites

Build your own query suite configurations.

### Step 1: Generate Template

```bash
./create-custom-suite.sh
```

**Options:**

```text
Create Custom Query Suite:
1. High severity security only
2. Critical security issues
3. Code quality focus
4. Memory safety focus
5. Custom configuration

Select template:
```

### Step 2: High Severity Suite

Create `custom-suites/high-severity-only.qls`:

```yaml
# High severity security issues only
- description: "High severity security issues (>= 8.0)"
- queries: .
- from: codeql/cpp-queries
- include:
    tags:
      - security
    query path:
      - "**/Security/**"
- exclude:
    tags:
      - experimental
```

### Step 3: Run Custom Suite

```bash
# C++
codeql database analyze \
    ../05-cpp-cmake-setup/databases/test-cpp-db \
    custom-suites/high-severity-only.qls \
    --format=sarif-latest \
    --output=results/cpp-custom-high-severity.sarif

# Rust
codeql database analyze \
    ../04-rust-setup/databases/test-rust-db \
    custom-suites/high-severity-only.qls \
    --format=sarif-latest \
    --output=results/rust-custom-high-severity.sarif
```

### Step 4: Memory Safety Suite (C++)

Create `custom-suites/memory-safety.qls`:

```yaml
# Memory safety focus
- description: "Memory safety issues"
- queries: .
- from: codeql/cpp-queries
- include:
    tags:
      - security
    query path:
      - "**/Security/CWE/CWE-119/**"  # Buffer overflow
      - "**/Security/CWE/CWE-401/**"  # Memory leak
      - "**/Security/CWE/CWE-416/**"  # Use after free
      - "**/Security/CWE/CWE-476/**"  # Null dereference
    precision:
      - very-high
      - high
```

### Step 5: Code Quality Suite (Rust)

Create `custom-suites/rust-quality.qls`:

```yaml
# Rust code quality focus
- description: "Rust code quality issues"
- queries: .
- from: codeql/rust-queries
- include:
    tags:
      - correctness
      - maintainability
    precision:
      - very-high
      - high
- exclude:
    tags:
      - experimental
    query path:
      - "**/test/**"
```

## 📈 Exercise 6: Performance Comparison

Measure and compare execution times.

### Step 1: Time Each Suite

```bash
# Code scanning (fast)
time codeql database analyze \
    ../05-cpp-cmake-setup/databases/test-cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-code-scanning.qls \
    --format=sarif-latest \
    --output=results/cpp-code-scanning-timed.sarif

# Security and quality (medium)
time codeql database analyze \
    ../05-cpp-cmake-setup/databases/test-cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-security-and-quality.qls \
    --format=sarif-latest \
    --output=results/cpp-security-quality-timed.sarif
```

### Step 2: Compare Query Counts

```bash
# Count queries run in each suite
for file in results/*.sarif; do
    queries=$(jq '.runs[0].tool.driver.rules | length' $file)
    results=$(jq '.runs[0].results | length' $file)
    echo "$(basename $file): $queries queries → $results findings"
done
```

### Step 3: Optimize Performance

```bash
# Use more threads
codeql database analyze \
    ../05-cpp-cmake-setup/databases/test-cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-security-extended.qls \
    --format=sarif-latest \
    --output=results/cpp-optimized.sarif \
    --threads=$(nproc) \
    --ram=$(($(free -m | awk '/^Mem:/{print $2}') * 80 / 100))
```

## 🎓 Exercise 7: Interpretation Practice

Practice interpreting real findings.

### Step 1: Review Critical Findings

```bash
# Extract error-level findings with details
jq -r '.runs[0].results[] | 
    select(.level == "error") | 
    "---\n" +
    "Rule: \(.ruleId)\n" +
    "Severity: \(.rule.properties."security-severity")\n" +
    "Precision: \(.rule.properties.precision)\n" +
    "Message: \(.message.text)\n" +
    "Location: \(.locations[0].physicalLocation.artifactLocation.uri):\
\(.locations[0].physicalLocation.region.startLine)\n" +
    "CWE: \(.rule.properties.tags | map(select(startswith("external/cwe"))) 
    | join(", "))"' \
    results/cpp-security-and-quality.sarif
```

### Step 2: Analyze False Positives

Review each finding and categorize:

```text
Categorization Guide:
✅ True Positive: Real vulnerability, must fix
⚠️  Needs Context: Could be issue, investigate
❌ False Positive: Not actually a problem
📝 Best Practice: Not vulnerable, but improve code
```

### Step 3: Create Action Plan

Based on findings, create prioritized action plan:

```text
Priority 1 (Fix Immediately):
  - Very high precision + error level
  - Security severity >= 9.0
  - Found by all query suites

Priority 2 (Fix This Sprint):
  - High precision + error level
  - Security severity >= 7.0
  - Found by 2+ query suites

Priority 3 (Technical Debt):
  - Medium/high precision + warning level
  - Security severity < 7.0
  - Code quality issues

Priority 4 (Future Improvement):
  - Recommendations
  - Low priority quality issues
```

## 🔍 Exercise 8: Incremental Analysis

Practice comparing results over time.

### Step 1: Create Baseline

```bash
# Save current results as baseline
cp results/cpp-security-and-quality.sarif \
    results/baseline-$(date +%Y%m%d).sarif
```

### Step 2: Simulate Code Changes

```bash
# (In real workflow, this is after code changes)
# For lab, we'll compare different suites
cp results/cpp-security-extended.sarif \
    results/new-results.sarif
```

### Step 3: Find New Issues

```bash
# Extract new issues (simplified comparison)
jq --slurpfile baseline results/baseline-*.sarif \
   -r '.runs[0].results[] | 
   select(.ruleId as $id | 
   ($baseline[0].runs[0].results | 
   map(.ruleId) | contains([$id]) | not)) | 
   "\(.ruleId): \(.message.text)"' \
   results/new-results.sarif
```

## 💡 Challenge Exercises

### Challenge 1: Multi-Language Analysis

Run analysis on both C++ and Rust projects and compare:

```bash
# Run same suite on both languages
./run-all-suites.sh --language=cpp
./run-all-suites.sh --language=rust

# Compare findings density
cpp_loc=$(find ../05-cpp-cmake-setup/test-cpp-project/src -name "*.cpp" \
    -o -name "*.h" | xargs wc -l | tail -1 | awk '{print $1}')
rust_loc=$(find ../04-rust-setup/test-rust-project/src -name "*.rs" \
    | xargs wc -l | tail -1 | awk '{print $1}')

cpp_findings=$(jq '.runs[0].results | length' \
    results/cpp-security-and-quality.sarif)
rust_findings=$(jq '.runs[0].results | length' \
    results/rust-security-and-quality.sarif)

echo "C++: $cpp_findings findings per $cpp_loc LOC"
echo "Rust: $rust_findings findings per $rust_loc LOC"
```

### Challenge 2: Custom Filtering Pipeline

Create a pipeline that:
1. Runs security-extended suite
2. Filters to high precision only
3. Groups by CWE category
4. Generates summary report

```bash
#!/bin/bash
# custom-pipeline.sh

# Run analysis
codeql database analyze ../05-cpp-cmake-setup/databases/test-cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-security-extended.qls \
    --format=sarif-latest \
    --output=results/pipeline-input.sarif

# Filter high precision
jq '.runs[0].results |= 
    map(select(.rule.properties.precision == "high" or 
    .rule.properties.precision == "very-high"))' \
    results/pipeline-input.sarif > results/pipeline-filtered.sarif

# Group by CWE
jq -r '.runs[0].results | 
    group_by(.rule.properties.tags | 
    map(select(startswith("external/cwe"))) | .[0]) | 
    map({cwe: .[0].rule.properties.tags | 
    map(select(startswith("external/cwe"))) | .[0], 
    count: length, 
    rules: [.[].ruleId] | unique}) | 
    .[] | "\(.cwe): \(.count) findings in \(.rules | length) rules"' \
    results/pipeline-filtered.sarif > results/cwe-summary.txt
```

### Challenge 3: ROI Analysis

Calculate the "return on investment" for each suite:

```bash
# findings_per_minute = findings / execution_time_minutes
# high_value_findings = error_level + security_severity >= 8.0

# Calculate for each suite and determine optimal choice
```

## 📊 Expected Results

### Test Project Findings (C++)

The test C++ project should reveal:

- **Buffer overflow** (CWE-120): strcpy without bounds check
- **Null pointer dereference** (CWE-476): Missing null check
- **Memory leak** (CWE-401): Allocated memory not freed
- **Use after free** (CWE-416): Access to freed memory
- **Integer overflow** (CWE-190): Unchecked arithmetic
- **Command injection** (CWE-78): Unsafe system call

### Test Project Findings (Rust)

The test Rust project should reveal:

- **Unwrap abuse**: Potential panics from unwrap()
- **Unused variables**: Declared but never used
- **Unreachable code**: Code after unconditional return
- **Redundant clones**: Unnecessary performance overhead
- **Integer overflow**: Unchecked arithmetic in debug mode
- **Empty loops**: Inefficient or incorrect logic

## ✅ Verification

Check your work:

```bash
# Should have results for multiple suites
ls -lh results/*.sarif

# Should show different result counts
for f in results/*.sarif; do 
    echo "$f: $(jq '.runs[0].results | length' $f)"
done

# Should have custom suites
ls custom-suites/*.qls
```

## 🎓 Key Takeaways

After completing this lab, you should understand:

1. **Suite Selection**: When to use each query suite
   - code-scanning for CI/CD
   - security-and-quality for development
   - security-extended for audits

2. **Result Interpretation**: How to prioritize findings
   - Severity levels matter
   - Precision indicates false positive rate
   - Multiple suites agreeing = high confidence

3. **Customization**: How to create custom suites
   - Include/exclude patterns
   - Filter by tags and precision
   - Focus on specific CWE categories

4. **Performance**: Trade-offs between speed and coverage
   - More queries = longer execution
   - More findings ≠ better results
   - Right suite for the right purpose

## 📚 Additional Resources

- [Query Suite Documentation](https://codeql.github.com/docs/codeql-cli/creating-codeql-query-suites/)
- [SARIF Specification](https://sarifweb.azurewebsites.net/)
- [CWE Database](https://cwe.mitre.org/)

## ⏭️ Next Steps

- Continue to Lab 07: Coding Standards (MISRA & CERT)
- Explore custom query development
- Integrate with CI/CD pipelines

---

*💡 Pro Tip: Start with code-scanning suite in CI/CD, graduate to
security-and-quality as your team gets comfortable with CodeQL, and
run security-extended monthly for deep security reviews.*
