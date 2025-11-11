# 🦀 Lab 04: Rust Setup for CodeQL

## 📖 Overview

This lab provides hands-on experience with CodeQL analysis for Rust
projects. You'll learn how to create CodeQL databases, run security
and quality analyses, and interpret SARIF results.

## 🎯 Learning Objectives

By completing this lab, you will:

- ✓ Create CodeQL databases for Rust projects
- ✓ Run built-in security and quality queries
- ✓ Analyze SARIF output files
- ✓ Identify common Rust security issues
- ✓ Understand CodeQL workflow for Rust

## ✅ Prerequisites

Before starting, ensure you have:

1. **CodeQL CLI** installed (see `../03-installation/`)
2. **Rust toolchain** installed:

   ```bash
   rustc --version  # Should show 1.65.0 or later
   cargo --version
   ```

3. **CodeQL libraries** downloaded:

   ```bash
   codeql pack download codeql/rust-queries
   ```

4. **System resources**:
   - 4 GB RAM minimum (8 GB recommended)
   - 1 GB free disk space

## 📁 Lab Structure

```text
lab/04-rust-setup/
├── README.md                     # This file
├── create-rust-database.sh       # Script to create CodeQL database
├── analyze-rust-database.sh      # Script to run analysis
└── test-rust-project/            # Sample Rust project
    ├── Cargo.toml
    ├── src/
    │   ├── main.rs               # Main program
    │   └── lib.rs                # Intentionally problematic code
    └── target/                   # Build artifacts (auto-generated)
```

## 🚀 Getting Started

### Step 1: Navigate to Lab Directory

```bash
cd lab/04-rust-setup
```

### Step 2: Review the Test Project

The test project contains intentionally problematic code patterns:

```bash
# View the main program
cat test-rust-project/src/main.rs

# View the library with security issues
cat test-rust-project/src/lib.rs
```

**Issues included:**

- ❌ Unwrap abuse (can panic)
- ❌ Unused variables
- ❌ Unreachable code
- ❌ Redundant clones
- ❌ Integer overflow potential
- ❌ Empty loops
- ❌ Unsafe array indexing
- ❌ Ignored parse errors

### Step 3: Create CodeQL Database

Run the database creation script:

```bash
./create-rust-database.sh
```

**What this does:**

1. Checks that CodeQL is installed
2. Builds the Rust project with `cargo build`
3. Creates a CodeQL database in `databases/test-rust-db/`
4. Captures semantic information about the code

**Expected output:**

```text
🦀 Creating CodeQL Database for Rust Test Project
==================================================

📦 Building Rust project...
   Compiling codeql-test-rust v0.1.0
✓ Project built successfully

🔍 Creating CodeQL database...
This may take a minute...

✅ Database created: ./databases/test-rust-db

Next: Run ./analyze-rust-database.sh to analyze
```

**Duration:** 30-60 seconds

### Step 4: Run CodeQL Analysis

Execute the analysis script:

```bash
./analyze-rust-database.sh
```

**What this does:**

1. Verifies the database exists
2. Runs the `rust-security-and-quality` query suite
3. Generates SARIF output in `results/rust-results.sarif`
4. Shows a summary of findings (if `jq` is installed)

**Expected output:**

```text
🦀 Analyzing Rust Database with CodeQL
=======================================

🚀 Running security and quality analysis...
Query suite: rust-security-and-quality

✅ Analysis complete!

📄 Results saved to: ./results/rust-results.sarif

📊 Summary:
  Found 8 issues

Top issues:
  - rust/unused-variable: Unused variable 'x'
  - rust/unwrap-result: Use of 'unwrap' on Result
  - rust/unreachable-code: Unreachable code
  ...
```

**Duration:** 1-3 minutes

### Step 5: Review Results

Examine the SARIF output:

#### Option A: Using VS Code (Recommended)

```bash
# Open in VS Code
code results/rust-results.sarif
```

Install the SARIF Viewer extension for best experience:

```bash
code --install-extension MS-SarifVSCode.sarif-viewer
```

#### Option B: Using `jq` (Command-line)

```bash
# Count total issues
jq '.runs[0].results | length' results/rust-results.sarif

# List all issue types
jq -r '.runs[0].results[].ruleId' results/rust-results.sarif | sort | uniq

# Show first 5 issues with details
jq '.runs[0].results[0:5] | .[] | 
    "\(.ruleId): \(.message.text) at \(.locations[0].physicalLocation.artifactLocation.uri):\(.locations[0].physicalLocation.region.startLine)"' \
    results/rust-results.sarif
```

#### Option C: Using Python

```python
import json

with open('results/rust-results.sarif') as f:
    data = json.load(f)

results = data['runs'][0]['results']
print(f"Total issues found: {len(results)}")

for result in results[:5]:
    rule_id = result['ruleId']
    message = result['message']['text']
    location = result['locations'][0]['physicalLocation']
    file = location['artifactLocation']['uri']
    line = location['region']['startLine']
    print(f"{rule_id}: {message} at {file}:{line}")
```

## 🔍 Understanding the Results

### Expected Findings

The test project should generate findings similar to:

| Rule ID | Description | File | Line |
|---------|-------------|------|------|
| `rust/unused-variable` | Unused variable 'x' | lib.rs | 7 |
| `rust/unwrap-result` | Use of 'unwrap' | lib.rs | 32 |
| `rust/unreachable-code` | Code after return | lib.rs | 23 |
| `rust/redundant-clone` | Unnecessary clone | lib.rs | 44 |
| `rust/empty-loop` | Empty loop body | lib.rs | 52 |
| `rust/unsafe-index` | Unchecked indexing | lib.rs | 68 |

### Severity Levels

- **Error**: Critical issues that should be fixed immediately
- **Warning**: Potential problems worth investigating
- **Note**: Code quality suggestions

### SARIF Structure

Key sections in the SARIF file:

```json
{
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "CodeQL",
          "version": "...",
          "rules": [...]
        }
      },
      "results": [
        {
          "ruleId": "rust/unwrap-result",
          "level": "warning",
          "message": { "text": "..." },
          "locations": [...]
        }
      ]
    }
  ]
}
```

## 🔧 Customization

### Using Different Query Suites

Edit `analyze-rust-database.sh` to use different query suites:

**Security Extended (more queries, more false positives):**

```bash
QUERY_SUITE="$CODEQL_HOME/codeql-repo/rust/ql/src/codeql-suites/rust-security-extended.qls"
```

**Code Scanning (GitHub optimized):**

```bash
QUERY_SUITE="$CODEQL_HOME/codeql-repo/rust/ql/src/codeql-suites/rust-code-scanning.qls"
```

### Adjusting Performance

Modify resources in `analyze-rust-database.sh`:

```bash
# Use more CPU cores
--threads=8

# Allocate more RAM (in MB)
--ram=16384
```

### Analyzing Your Own Project

Replace the test project with your own:

```bash
# In create-rust-database.sh, change:
PROJECT_DIR="/path/to/your/rust/project"
```

Or create a database manually:

```bash
codeql database create my-project-db \
    --language=rust \
    --source-root=/path/to/your/project
```

Then analyze:

```bash
codeql database analyze my-project-db \
    codeql/rust-queries:codeql-suites/rust-security-and-quality.qls \
    --format=sarif-latest \
    --output=my-results.sarif
```

## 🧪 Exercises

### Exercise 1: Fix Unwrap Issues

1. Open `test-rust-project/src/lib.rs`
2. Find the `unwrap_abuse_example` function
3. Rewrite it to return a `Result` instead of panicking
4. Recreate the database and verify the issue is resolved

### Exercise 2: Investigate Severity

1. Review all findings in the SARIF file
2. Categorize them by severity (error/warning/note)
3. Create a priority list for fixes

### Exercise 3: Custom Analysis

1. Create a new Rust project with your own code
2. Run CodeQL analysis on it
3. Document any findings and fix them

### Exercise 4: Query Comparison

1. Run analysis with `rust-security-extended.qls`
2. Compare results with `rust-code-scanning.qls`
3. Note differences in findings

## 🐛 Troubleshooting

### Issue: "CodeQL not found"

**Solution:**

```bash
# Check CodeQL installation
which codeql

# Verify environment variable
echo $CODEQL_HOME

# Re-run installation
cd ../03-installation
./install-codeql.sh
```

### Issue: "Cargo build failed"

**Solution:**

```bash
# Test build manually
cd test-rust-project
cargo build

# Check Rust installation
rustc --version
rustup show

# Update Rust if needed
rustup update
```

### Issue: "Database creation stuck"

**Solution:**

- Check available disk space: `df -h`
- Check available memory: `free -h`
- Kill and retry: `pkill codeql; ./create-rust-database.sh`

### Issue: "No results found"

**Solution:**

- Ensure database was created successfully
- Check query suite path exists
- Verify CodeQL libraries are downloaded:

  ```bash
  codeql pack download codeql/rust-queries
  ls $CODEQL_HOME/codeql-repo/rust/ql/src/codeql-suites/
  ```

### Issue: "jq not found"

**Solution:**

```bash
# Install jq for JSON parsing
sudo apt install jq  # Ubuntu/Debian
brew install jq      # macOS
```

## 📊 Expected Results Summary

After completing this lab, you should have:

- ✅ A CodeQL database in `databases/test-rust-db/`
- ✅ SARIF results in `results/rust-results.sarif`
- ✅ 6-10 findings from the analysis
- ✅ Understanding of common Rust security issues
- ✅ Experience with CodeQL workflow

## 📚 Additional Resources

### CodeQL Documentation

- [CodeQL for Rust](https://codeql.github.com/docs/codeql-language-guides/codeql-for-rust/)
- [Rust Query Reference](https://codeql.github.com/codeql-standard-libraries/rust/)
- [CodeQL CLI Reference](https://codeql.github.com/docs/codeql-cli/)

### Rust Security

- [Rust Security Guidelines](https://anssi-fr.github.io/rust-guide/)
- [Common Rust Security Issues](https://rust-lang.github.io/rfcs/1214-projections-lifetimes-and-wf.html)

### SARIF Tools

- [SARIF Viewer (VS Code)](https://marketplace.visualstudio.com/items?itemName=MS-SarifVSCode.sarif-viewer)
- [SARIF Specification](https://sarifweb.azurewebsites.net/)
- [SARIF Tutorials](https://github.com/microsoft/sarif-tutorials)

## ⏭️ Next Steps

After completing this lab:

1. **Read the main guide**: `../../04-rust-setup.md`
2. **Try C++ analysis**: Move to `../05-cpp-cmake-setup/`
3. **Explore query suites**: Learn about built-in queries
4. **Analyze real projects**: Apply CodeQL to your own code

## 💡 Tips

- **Start simple**: Begin with the default query suite
- **Read findings carefully**: Not all warnings are critical
- **Prioritize fixes**: Focus on high-severity issues first
- **Automate**: Integrate CodeQL into CI/CD pipelines
- **Learn queries**: Study how queries detect issues
- **Share results**: Use SARIF for team collaboration

## 🤝 Contributing

Found an issue in the lab? Improvements to suggest?

- Open an issue in the repository
- Submit a pull request with fixes
- Share your experience and findings

---

Happy analyzing! 🦀🔍
