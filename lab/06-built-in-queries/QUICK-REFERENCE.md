# Lab 06 - Quick Reference

## 🚀 Getting Started

```bash
cd lab/06-built-in-queries
./quick-start.sh
```

## 📋 Available Scripts

| Script | Purpose | Example |
|--------|---------|---------|
| `quick-start.sh` | Interactive menu | `./quick-start.sh` |
| `run-all-suites.sh` | Run all query suites | `./run-all-suites.sh` |
| `compare-suites.sh` | Compare suite results | `./compare-suites.sh` |
| `analyze-by-severity.sh` | Analyze by severity | `./analyze-by-severity.sh results/cpp-*.sarif` |
| `filter-results.sh` | Filter SARIF results | `./filter-results.sh results/cpp-*.sarif` |
| `create-custom-suite.sh` | Create custom suite | `./create-custom-suite.sh` |

## 🎯 Common Tasks

### Run a Specific Suite

```bash
# Code scanning (fast)
codeql database analyze ../05-cpp-cmake-setup/databases/test-cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-code-scanning.qls \
    --format=sarif-latest \
    --output=results/cpp-code-scanning.sarif

# Security and quality (balanced)
codeql database analyze ../05-cpp-cmake-setup/databases/test-cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-security-and-quality.qls \
    --format=sarif-latest \
    --output=results/cpp-security-and-quality.sarif
```

### Filter Results

```bash
# By severity
./filter-results.sh results/cpp-security-and-quality.sarif severity error

# By precision
./filter-results.sh results/cpp-security-and-quality.sarif precision very-high

# By security score
./filter-results.sh results/cpp-security-and-quality.sarif score 8.0

# By CWE
./filter-results.sh results/cpp-security-and-quality.sarif cwe cwe-119
```

### Analyze Results

```bash
# Count findings
jq '.runs[0].results | length' results/cpp-security-and-quality.sarif

# List unique rule IDs
jq -r '.runs[0].results[].ruleId' results/cpp-security-and-quality.sarif | sort -u

# Show error-level issues
jq -r '.runs[0].results[] | select(.level == "error") | 
    "\(.ruleId): \(.message.text)"' results/cpp-security-and-quality.sarif

# Group by severity
jq '.runs[0].results | group_by(.level) | 
    map({severity: .[0].level, count: length})' \
    results/cpp-security-and-quality.sarif
```

## 📚 Custom Query Suites

Pre-made custom suites in `custom-suites/`:

- `high-severity-security.qls` - High severity issues only (>= 8.0)
- `cpp-memory-safety.qls` - C++ memory safety focus
- `code-quality.qls` - Code quality and maintainability

### Use a Custom Suite

```bash
codeql database analyze ../05-cpp-cmake-setup/databases/test-cpp-db \
    custom-suites/high-severity-security.qls \
    --format=sarif-latest \
    --output=results/custom-high-severity.sarif
```

## 💡 Tips

1. **Start Small**: Run code-scanning first, then graduate to larger suites
2. **Filter Early**: Use high precision filters to reduce noise
3. **Focus on Errors**: Error-level findings should be fixed first
4. **Check Security Scores**: Issues with score >= 8.0 are critical
5. **Compare Suites**: Issues found by multiple suites are high confidence

## 📊 Expected Results

### C++ Test Project
- Buffer overflow (CWE-120)
- Null pointer dereference (CWE-476)
- Memory leak (CWE-401)
- Use after free (CWE-416)
- Integer overflow (CWE-190)
- Command injection (CWE-78)

### Rust Test Project
- Unwrap abuse
- Unused variables
- Unreachable code
- Redundant clones
- Integer overflow
- Empty loops

## 🔍 Troubleshooting

**No databases found?**
```bash
cd ../05-cpp-cmake-setup && ./create-cpp-database.sh
cd ../04-rust-setup && ./create-rust-database.sh
```

**jq not installed?**
```bash
sudo apt-get install jq
```

**Query pack not found?**
```bash
codeql pack download codeql/cpp-queries
codeql pack download codeql/rust-queries
```

## ⏭️ Next Steps

1. Complete all exercises in README.md
2. Try filtering by different criteria
3. Create your own custom suite
4. Continue to Lab 07 (Coding Standards)
