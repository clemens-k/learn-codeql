# 🔍 Using Built-in Query Suites

## 📖 Overview

CodeQL comes with hundreds of pre-built queries organized into query
suites. These queries detect security vulnerabilities, code quality
issues, and coding standard violations. This guide shows you how to
use these powerful built-in queries effectively.

---

## 🎯 What You'll Learn

- Understanding query packs and query suites
- Available built-in query suites for C++ and Rust
- How to run different query suites
- Interpreting and filtering results
- Customizing query suite execution
- Performance considerations

---

## 📦 Query Packs vs Query Suites

### Query Packs

A **query pack** is a collection of queries, libraries, and metadata
bundled together:

- Published and versioned
- Can be downloaded and shared
- Include dependencies
- Standard format for distribution

**Examples:**

- `codeql/cpp-queries` - C++ query pack
- `codeql/rust-queries` - Rust query pack
- `codeql/python-queries` - Python query pack

### Query Suites

A **query suite** is a selection of queries from a pack, organized by
purpose:

- `.qls` files (Query List Specification)
- Group queries by category (security, quality, etc.)
- Control which queries run
- Can include/exclude specific queries

**Think of it as**: Query pack = library, Query suite = playlist

---

## 🗂️ Standard Query Suites

### C++ Query Suites

CodeQL provides several pre-built C++ query suites:

#### 1. `cpp-code-scanning.qls` (Production)

**Best for**: GitHub Code Scanning, CI/CD pipelines

**Focus**: High-confidence security vulnerabilities

**Characteristics**:
- Low false positive rate
- Production-ready
- Fast execution
- Critical issues only

**Use when**: You want reliable, actionable results in production

#### 2. `cpp-security-and-quality.qls` (Recommended)

**Best for**: Development, pre-commit checks

**Focus**: Security + code quality

**Characteristics**:
- Balanced precision/recall
- Security and maintainability
- Moderate execution time
- **Most popular choice**

**Use when**: You want comprehensive analysis during development

#### 3. `cpp-security-extended.qls` (Comprehensive)

**Best for**: Security audits, deep analysis

**Focus**: All security-related queries

**Characteristics**:
- Highest coverage
- More false positives
- Longer execution time
- Experimental queries included

**Use when**: Conducting thorough security review

#### 4. `cpp-lgtm.qls` (Legacy)

**Best for**: LGTM.com compatibility

**Note**: Being phased out, use `cpp-code-scanning.qls` instead

### Rust Query Suites

Similar structure for Rust:

#### 1. `rust-code-scanning.qls` (Production)

High-confidence security issues for production use

#### 2. `rust-security-and-quality.qls` (Recommended)

Balanced security and quality checks

#### 3. `rust-security-extended.qls` (Comprehensive)

All security queries including experimental ones

---

## 🚀 Running Query Suites

### Basic Syntax

```bash
codeql database analyze <database> \
    <query-suite> \
    --format=<format> \
    --output=<output-file>
```

### C++ Examples

**Production scanning:**

```bash
codeql database analyze cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-code-scanning.qls \
    --format=sarif-latest \
    --output=results.sarif
```

**Development analysis:**

```bash
codeql database analyze cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-security-and-quality.qls \
    --format=sarif-latest \
    --output=results.sarif
```

**Security audit:**

```bash
codeql database analyze cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-security-extended.qls \
    --format=sarif-latest \
    --output=audit-results.sarif
```

### Rust Examples

**Production scanning:**

```bash
codeql database analyze rust-db \
    codeql/rust-queries:codeql-suites/rust-code-scanning.qls \
    --format=sarif-latest \
    --output=results.sarif
```

**Development analysis:**

```bash
codeql database analyze rust-db \
    codeql/rust-queries:codeql-suites/rust-security-and-quality.qls \
    --format=sarif-latest \
    --output=results.sarif
```

### Using Local Query Suites

If you have the CodeQL repository cloned:

```bash
# C++
codeql database analyze cpp-db \
    $CODEQL_HOME/codeql-repo/cpp/ql/src/codeql-suites/\
cpp-security-and-quality.qls \
    --format=sarif-latest \
    --output=results.sarif

# Rust
codeql database analyze rust-db \
    $CODEQL_HOME/codeql-repo/rust/ql/src/codeql-suites/\
rust-security-and-quality.qls \
    --format=sarif-latest \
    --output=results.sarif
```

---

## 📊 Query Categories

Queries are organized by category. Here are the main categories:

### Security Queries

Detect security vulnerabilities:

| Category | C++ Examples | Rust Examples |
|----------|--------------|---------------|
| **Injection** | SQL, Command, Path | Command, Format String |
| **Memory** | Buffer overflow, UAF | Unsafe operations |
| **Crypto** | Weak algorithms | Insecure random |
| **Auth** | Hardcoded credentials | Token leaks |
| **XSS** | Cross-site scripting | HTML injection |

### Code Quality Queries

Identify maintainability issues:

| Category | C++ Examples | Rust Examples |
|----------|--------------|---------------|
| **Complexity** | Deep nesting | Cognitive complexity |
| **Duplication** | Copy-paste code | Duplicate logic |
| **Dead Code** | Unused functions | Unreachable code |
| **Naming** | Poor identifiers | Convention violations |
| **Design** | Long functions | Missing error handling |

### Reliability Queries

Find potential bugs:

| Category | C++ Examples | Rust Examples |
|----------|--------------|---------------|
| **Null Safety** | Null dereference | Unwrap abuse |
| **Resources** | Memory leaks | Resource leaks |
| **Logic** | Off-by-one errors | Logic errors |
| **Concurrency** | Data races | Arc/Mutex issues |

---

## 🎯 Running Specific Categories

### By Severity Level

Filter queries by severity:

```bash
# Only error-level queries
codeql database analyze cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-security-and-quality.qls \
    --format=sarif-latest \
    --output=results.sarif \
    --severity=error

# Warning and above
--severity=warning

# Include recommendations
--severity=recommendation
```

### By CWE Category

Target specific CWE (Common Weakness Enumeration) categories:

```bash
# Buffer overflows (CWE-119)
codeql database analyze cpp-db \
    $CODEQL_HOME/codeql-repo/cpp/ql/src/Security/CWE/CWE-119/ \
    --format=sarif-latest \
    --output=buffer-overflow-results.sarif

# Injection flaws (CWE-78)
$CODEQL_HOME/codeql-repo/cpp/ql/src/Security/CWE/CWE-078/
```

### Custom Query Selection

Create a custom `.qls` file:

```yaml
# custom-queries.qls
- description: "My custom query suite"
- queries: .
- include:
    kind:
      - problem
      - path-problem
    tags:
      - security
      - correctness
- exclude:
    tags:
      - experimental
```

Run your custom suite:

```bash
codeql database analyze cpp-db custom-queries.qls \
    --format=sarif-latest \
    --output=custom-results.sarif
```

---

## 📈 Interpreting Results

### Understanding Query Metadata

Each query includes metadata:

```ql
/**
 * @name Buffer overflow
 * @description Writing beyond buffer bounds
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id cpp/buffer-overflow
 * @tags security
 *       external/cwe/cwe-119
 */
```

**Key fields:**

- `@name`: Human-readable query name
- `@kind`: Result type (problem, path-problem, etc.)
- `@problem.severity`: Impact level (error, warning, recommendation)
- `@security-severity`: CVSS-style score (0.0-10.0)
- `@precision`: False positive rate (low, medium, high, very-high)
- `@id`: Unique query identifier
- `@tags`: Categories and CWE mappings

### Result Severity Levels

**Error** (🔴):
- Critical security issues
- High-confidence bugs
- Must fix before release

**Warning** (🟡):
- Likely problems
- Security concerns
- Should fix

**Recommendation** (🔵):
- Code quality improvements
- Best practice violations
- Consider fixing

**Note** (⚪):
- Informational
- Style suggestions
- Optional improvements

### Precision Levels

**Very High**:
- Extremely low false positive rate
- Almost always a real issue
- Act immediately

**High**:
- Low false positive rate
- Usually a real problem
- High priority

**Medium**:
- Some false positives expected
- Requires human judgment
- Review carefully

**Low**:
- Higher false positive rate
- May need context to verify
- Use for exploration

---

## 🔧 Advanced Usage

### Performance Options

**Threading:**

```bash
codeql database analyze cpp-db queries.qls \
    --format=sarif-latest \
    --output=results.sarif \
    --threads=16
```

**RAM allocation:**

```bash
--ram=16384  # 16 GB
```

**Timeout per query:**

```bash
--timeout=300  # 5 minutes per query
```

### Multiple Query Suites

Run multiple suites and merge results:

```bash
# Run security suite
codeql database analyze cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-security-extended.qls \
    --format=sarif-latest \
    --output=security-results.sarif

# Run quality suite
codeql database analyze cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-code-scanning.qls \
    --format=sarif-latest \
    --output=quality-results.sarif

# Merge with jq
jq -s '.[0] * .[1]' security-results.sarif quality-results.sarif \
    > combined-results.sarif
```

### Incremental Analysis

For faster re-analysis:

```bash
# First run (full)
codeql database analyze cpp-db queries.qls \
    --format=sarif-latest \
    --output=results.sarif

# Save results for comparison
cp results.sarif baseline.sarif

# After code changes, compare
codeql database analyze cpp-db queries.qls \
    --format=sarif-latest \
    --output=new-results.sarif

# Find new issues
jq --slurpfile baseline baseline.sarif \
   '.runs[0].results - $baseline[0].runs[0].results' \
   new-results.sarif
```

### Filtering Results

**By file path:**

```bash
# Only analyze src/ directory
codeql database analyze cpp-db queries.qls \
    --format=sarif-latest \
    --output=results.sarif \
    -- --include='src/**'

# Exclude tests
-- --exclude='test/**'
```

**Post-processing with jq:**

```bash
# Only errors
jq '.runs[0].results |= map(select(.level == "error"))' \
    results.sarif > errors-only.sarif

# Specific CWE
jq '.runs[0].results |= 
    map(select(.rule.properties.tags | 
    contains(["external/cwe/cwe-119"])))' \
    results.sarif > buffer-overflows.sarif

# High severity only
jq '.runs[0].results |= 
    map(select(.rule.properties."security-severity" >= 7.0))' \
    results.sarif > high-severity.sarif
```

---

## 📋 Query Suite Comparison

### When to Use Each Suite

| Scenario | C++ Suite | Rust Suite | Rationale |
|----------|-----------|------------|-----------|
| **CI/CD Pipeline** | code-scanning | code-scanning | Fast, low FP |
| **Pull Request** | security-and-quality | security-and-quality | Balanced |
| **Security Audit** | security-extended | security-extended | Comprehensive |
| **Pre-commit** | code-scanning | code-scanning | Quick feedback |
| **Release Gate** | security-and-quality | security-and-quality | Thorough |
| **Exploration** | security-extended | security-extended | Find everything |

### Execution Time Comparison

Approximate times for medium-sized project (100K LOC):

| Suite | C++ Time | Rust Time | Query Count |
|-------|----------|-----------|-------------|
| code-scanning | 5-10 min | 3-5 min | ~50 queries |
| security-and-quality | 15-30 min | 10-15 min | ~150 queries |
| security-extended | 30-60 min | 15-30 min | ~300 queries |

*Times vary significantly based on project complexity and hardware*

---

## 🎯 Best Practices

### 1. Start Small

Begin with `code-scanning` suite:

```bash
# First analysis
codeql database analyze cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-code-scanning.qls \
    --format=sarif-latest \
    --output=results.sarif
```

Fix all issues, then graduate to `security-and-quality`.

### 2. Regular Scanning

Establish a cadence:

- **Daily**: code-scanning suite on main branch
- **Weekly**: security-and-quality suite
- **Monthly**: security-extended suite for deep review
- **Per PR**: code-scanning suite

### 3. Baseline and Track

Establish a baseline:

```bash
# Initial scan
codeql database analyze cpp-db queries.qls \
    --format=sarif-latest \
    --output=baseline-$(date +%Y%m%d).sarif

# Track over time
mkdir baselines/
cp results.sarif baselines/baseline-$(date +%Y%m%d).sarif
```

### 4. Focus on High Impact

Prioritize by security-severity and precision:

```bash
# Critical issues only
jq '.runs[0].results |= 
    map(select(
        .rule.properties."security-severity" >= 9.0 and
        .rule.properties.precision == "very-high"
    ))' results.sarif
```

### 5. Customize for Your Project

Create project-specific suite:

```yaml
# project-queries.qls
- description: "Project security checks"
- queries: .
- from: codeql/cpp-queries
- include:
    tags:
      - security
      - correctness
    precision:
      - high
      - very-high
- exclude:
    tags:
      - experimental
    query path:
      - "**/test/**"
```

---

## 🧪 Hands-On Exercise

Practice with the lab projects in `lab/06-built-in-queries/`:

### Quick Start

```bash
cd lab/06-built-in-queries
./quick-start.sh
```

This interactive script will guide you through:
- Running query suites
- Comparing results
- Creating custom suites

### Lab Structure

The lab includes:
- **Scripts**: Automated analysis and comparison tools
- **Custom Suites**: Pre-made query suite templates
- **Exercises**: Hands-on practice with real results

See `lab/06-built-in-queries/README.md` for detailed exercises.

### C++ Analysis

```bash
cd lab/05-cpp-cmake-setup

# Run different suites
./analyze-cpp-database.sh  # Uses security-and-quality

# Try code-scanning suite
codeql database analyze databases/test-cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-code-scanning.qls \
    --format=sarif-latest \
    --output=results/cpp-code-scanning.sarif

# Compare results
jq '.runs[0].results | length' results/*.sarif
```

### Rust Analysis

```bash
cd lab/04-rust-setup

# Run different suites
./analyze-rust-database.sh  # Uses security-and-quality

# Try extended suite
codeql database analyze databases/test-rust-db \
    codeql/rust-queries:codeql-suites/rust-security-extended.qls \
    --format=sarif-latest \
    --output=results/rust-security-extended.sarif

# Count findings by severity
jq '.runs[0].results | group_by(.level) | 
    map({severity: .[0].level, count: length})' \
    results/rust-security-extended.sarif
```

---

## 🔍 Common Query Examples

### C++ Security Queries

**Buffer Overflow:**
- `cpp/buffer-overflow`
- `cpp/unbounded-write`

**Memory Safety:**
- `cpp/use-after-free`
- `cpp/memory-leak`
- `cpp/double-free`

**Null Pointer:**
- `cpp/null-dereference`
- `cpp/potential-null-dereference`

**Integer Issues:**
- `cpp/integer-overflow`
- `cpp/uncontrolled-arithmetic`

### Rust Quality Queries

**Error Handling:**
- `rust/unwrap-result`
- `rust/panic-in-result-fn`

**Code Quality:**
- `rust/unused-variable`
- `rust/unreachable-code`
- `rust/redundant-clone`

**Performance:**
- `rust/inefficient-regex`
- `rust/unnecessary-allocation`

---

## 📚 Additional Resources

### Official Documentation

- [Query Suite Documentation](https://codeql.github.com/docs/codeql-cli/creating-codeql-query-suites/)
- [C++ Query Reference](https://codeql.github.com/codeql-query-help/cpp/)
- [Rust Query Reference](https://codeql.github.com/codeql-query-help/rust/)

### Query Sources

- [C++ Queries on GitHub](https://github.com/github/codeql/tree/main/cpp/ql/src)
- [Rust Queries on GitHub](https://github.com/github/codeql/tree/main/rust/ql/src)

### Community

- [CodeQL Discussion Forum](https://github.com/github/codeql/discussions)
- [Query Writing Guide](https://codeql.github.com/docs/writing-codeql-queries/)

---

## ⏭️ Next Steps

Now that you understand built-in query suites:

1. **Practice**: Run different suites on the lab projects
2. **Analyze**: Apply to your own C++/Rust projects
3. **Learn Standards**: Continue to `07-coding-standards.md`
4. **Deep Dive**: Explore `08-sarif-output.md` for result processing

---

## 🎓 Summary

You've learned:

- ✓ Difference between query packs and query suites
- ✓ Available built-in suites for C++ and Rust
- ✓ When to use each query suite
- ✓ How to run and customize query execution
- ✓ Interpreting results by severity and precision
- ✓ Performance optimization and filtering
- ✓ Best practices for regular scanning

**Key Takeaway**: Built-in query suites provide powerful,
production-ready security and quality analysis. Start with
`code-scanning` for CI/CD, use `security-and-quality` for
development, and run `security-extended` for comprehensive audits.
Regular scanning with appropriate suites significantly improves code
security and quality.

---

*📝 Note: Query suites are regularly updated. Keep your CodeQL CLI
and query packs updated to benefit from new queries and improved
precision.*
