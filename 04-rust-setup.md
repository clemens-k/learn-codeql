# 🦀 Rust Setup for CodeQL

## 📖 Overview

This guide covers everything you need to know to use CodeQL with Rust
projects, from creating databases to analyzing code and interpreting
results.

---

## 🎯 What You'll Learn

- Rust-specific requirements for CodeQL
- Creating CodeQL databases for Rust projects
- Configuring Rust project analysis
- Running built-in security and quality queries
- Understanding SARIF output format
- Best practices for Rust analysis

---

## ✅ Prerequisites

Before starting with Rust analysis, ensure you have:

- ✓ CodeQL CLI installed (see `03-installation.md`)
- ✓ Rust toolchain installed (`rustc`, `cargo`)
- ✓ CodeQL standard libraries downloaded
- ✓ A Rust project to analyze (or use our test project)

Check your Rust installation:

```bash
rustc --version
cargo --version
```

---

## 🔧 Rust-Specific Requirements

### Language Support

CodeQL has **full support** for Rust, including:

- **Language version**: Rust 1.65.0 and later
- **Build systems**: Cargo (primary), custom build scripts
- **Project types**: Libraries, binaries, workspaces
- **Feature flags**: Full support for conditional compilation

### System Resources

For typical Rust projects:

- **RAM**: 4-8 GB minimum (16 GB recommended for large projects)
- **Disk**: 500 MB - 5 GB per database (varies by project size)
- **CPU**: Multi-core recommended for faster analysis

### Rust Toolchain Configuration

CodeQL works with any standard Rust installation. For best results:

```bash
# Use stable toolchain
rustup default stable

# Keep toolchain updated
rustup update

# Install necessary components
rustup component add rustfmt clippy
```

---

## 🗄️ Creating CodeQL Databases for Rust

### Basic Database Creation

A CodeQL database captures your Rust project's structure and semantics.

**Command Syntax:**

```bash
codeql database create <database-path> \
    --language=rust \
    --source-root=<project-path>
```

**Parameters:**

- `<database-path>`: Where to store the database (e.g., `./rust-db`)
- `--language=rust`: Specifies Rust as the target language
- `--source-root=<path>`: Root directory of your Rust project

### Example: Simple Project

```bash
codeql database create rust-db \
    --language=rust \
    --source-root=./my-rust-project
```

This command:

1. 🔍 Discovers your project structure
2. 🔨 Runs `cargo build` to compile your code
3. 📊 Extracts semantic information
4. 💾 Stores everything in `rust-db/`

### Example: Workspace Projects

For Cargo workspaces with multiple crates:

```bash
codeql database create workspace-db \
    --language=rust \
    --source-root=./my-workspace
```

CodeQL automatically detects and analyzes all workspace members.

### Build Customization

If your project needs custom build commands:

```bash
codeql database create rust-db \
    --language=rust \
    --source-root=./my-project \
    --command="cargo build --all-features"
```

Common scenarios:

```bash
# Build with specific features
--command="cargo build --features feature1,feature2"

# Build in release mode
--command="cargo build --release"

# Build specific workspace member
--command="cargo build -p my-crate"

# Build all targets
--command="cargo build --all-targets"
```

### Advanced Options

**Threading and Performance:**

```bash
codeql database create rust-db \
    --language=rust \
    --source-root=./my-project \
    --threads=8 \
    --ram=8192
```

**Verbose Output:**

```bash
codeql database create rust-db \
    --language=rust \
    --source-root=./my-project \
    --verbose
```

---

## ⚙️ Configuration for Rust Projects

### Database Configuration

CodeQL can be configured via `codeql-database.yml` in your project
root. Create this file for custom settings:

```yaml
name: "my-rust-project"
languages:
  - rust
primaryLanguage: rust
```

### Excluding Directories

To skip certain directories (e.g., generated code):

```yaml
paths-ignore:
  - target/
  - .cargo/
  - tests/fixtures/
```

### Custom Queries Configuration

Create `.codeqlmanifest.json` to specify query metadata:

```json
{
  "name": "my-rust-queries",
  "version": "1.0.0",
  "dependencies": {
    "codeql/rust-all": "*"
  }
}
```

---

## 🔍 Running Built-in Queries

### Available Query Suites

CodeQL provides several pre-built query suites for Rust:

1. **`rust-security-extended.qls`**
   - All security-related queries
   - Best for security audits
   - Higher false positive rate

2. **`rust-security-and-quality.qls`**
   - Security + code quality checks
   - **Recommended starting point**
   - Balanced precision/recall

3. **`rust-code-scanning.qls`**
   - Optimized for GitHub Code Scanning
   - Lower false positives
   - Production-ready queries

### Running Analysis

**Basic Analysis:**

```bash
codeql database analyze rust-db \
    codeql/rust-queries:codeql-suites/rust-security-and-quality.qls \
    --format=sarif-latest \
    --output=results.sarif
```

**With Performance Options:**

```bash
codeql database analyze rust-db \
    codeql/rust-queries:codeql-suites/rust-security-and-quality.qls \
    --format=sarif-latest \
    --output=results.sarif \
    --threads=8 \
    --ram=8192
```

### Query Suite Locations

If you cloned the CodeQL repository:

```bash
# Security and quality (recommended)
$CODEQL_HOME/codeql-repo/rust/ql/src/codeql-suites/\
rust-security-and-quality.qls

# Security extended
$CODEQL_HOME/codeql-repo/rust/ql/src/codeql-suites/\
rust-security-extended.qls

# Code scanning
$CODEQL_HOME/codeql-repo/rust/ql/src/codeql-suites/\
rust-code-scanning.qls
```

### Running Specific Queries

To run individual queries:

```bash
# Find all unwrap() calls
codeql database analyze rust-db \
    $CODEQL_HOME/codeql-repo/rust/ql/src/\
Security/CWE-754/UnwrapOnResult.ql \
    --format=sarif-latest \
    --output=unwrap-results.sarif
```

---

## 📊 Understanding Query Results

### Common Rust Security Issues Detected

CodeQL for Rust can find:

| Category | Examples |
|----------|----------|
| **Memory Safety** | Buffer overflows, use-after-free |
| **Error Handling** | Unwrap abuse, ignored Results |
| **Integer Issues** | Overflow, underflow, truncation |
| **Concurrency** | Data races, deadlocks |
| **Injection** | Command injection, path traversal |
| **Cryptography** | Weak algorithms, hardcoded keys |

### Example Findings

**Unwrap Abuse:**

```rust
// 🚨 CodeQL will flag this
fn process(input: Option<String>) -> String {
    input.unwrap()  // Can panic!
}

// ✅ Better approach
fn process(input: Option<String>) -> Result<String, Error> {
    input.ok_or(Error::MissingInput)
}
```

**Integer Overflow:**

```rust
// 🚨 Can panic in debug mode
fn calculate(a: i32, b: i32) -> i32 {
    a + b
}

// ✅ Checked arithmetic
fn calculate(a: i32, b: i32) -> Option<i32> {
    a.checked_add(b)
}
```

---

## 📄 SARIF Output Format

### What is SARIF?

**SARIF** (Static Analysis Results Interchange Format) is a JSON-based
format for static analysis tools. It's an OASIS standard (ISO/IEC
30134:2021).

### SARIF Structure

A CodeQL SARIF file contains:

```json
{
  "version": "2.1.0",
  "$schema": "https://...",
  "runs": [
    {
      "tool": { ... },
      "results": [
        {
          "ruleId": "rust/unwrap-result",
          "message": { "text": "..." },
          "locations": [ ... ],
          "level": "warning"
        }
      ]
    }
  ]
}
```

### Key SARIF Elements

**Result Object:**

- `ruleId`: Unique identifier for the query
- `message`: Human-readable description
- `locations`: Source code locations
- `level`: Severity (error, warning, note)
- `relatedLocations`: Additional context

**Location Object:**

```json
{
  "physicalLocation": {
    "artifactLocation": {
      "uri": "src/main.rs"
    },
    "region": {
      "startLine": 42,
      "endLine": 42,
      "startColumn": 5,
      "endColumn": 15
    }
  }
}
```

### Viewing SARIF Files

**1. VS Code SARIF Viewer Extension:**

```bash
# Install the extension
code --install-extension MS-SarifVSCode.sarif-viewer
```

Open any `.sarif` file in VS Code for interactive viewing.

**2. Command-line with `jq`:**

```bash
# Count total results
jq '.runs[0].results | length' results.sarif

# List all rule IDs
jq '.runs[0].results[].ruleId' results.sarif

# Show error-level findings
jq '.runs[0].results[] | select(.level == "error")' results.sarif

# Extract messages
jq '.runs[0].results[] | "\(.ruleId): \(.message.text)"' \
    results.sarif
```

**3. GitHub Code Scanning:**

Upload SARIF to GitHub:

```bash
# Using GitHub CLI
gh api repos/{owner}/{repo}/code-scanning/sarifs \
    -F sarif=@results.sarif \
    -F ref=refs/heads/main \
    -F commit_sha=$(git rev-parse HEAD)
```

### SARIF Output Options

CodeQL supports multiple SARIF versions:

```bash
# Latest version (recommended)
--format=sarif-latest

# SARIF 2.1.0
--format=sarifv2.1.0

# Include Markdown in results
--sarif-add-snippets
```

### Other Output Formats

Besides SARIF, CodeQL supports:

**CSV Format:**

```bash
codeql database analyze rust-db queries.qls \
    --format=csv \
    --output=results.csv
```

**JSON (raw):**

```bash
--format=json
```

**GraphViz (for paths):**

```bash
--format=dot
```

---

## 🧪 Hands-On Lab Exercise

A complete lab setup is available in `lab/04-rust-setup/`:

### Lab Structure

```text
lab/04-rust-setup/
├── create-rust-database.sh      # Create test database
├── analyze-rust-database.sh     # Run analysis
├── README.md                     # Lab instructions
└── test-rust-project/           # Sample Rust project
    ├── src/
    │   ├── main.rs              # Main program
    │   └── lib.rs               # Intentionally buggy code
    └── Cargo.toml
```

### Running the Lab

#### Step 1: Create the database

```bash
cd lab/04-rust-setup
./create-rust-database.sh
```

This builds the test project and creates a CodeQL database.

#### Step 2: Run the analysis

```bash
./analyze-rust-database.sh
```

This analyzes the database and generates SARIF output.

#### Step 3: Review results

```bash
# View with jq
jq '.runs[0].results[] | 
    "\(.ruleId): \(.message.text) at \(.locations[0].
    physicalLocation.artifactLocation.uri):\(.locations[0].
    physicalLocation.region.startLine)"' \
    results/rust-results.sarif

# Or open in VS Code
code results/rust-results.sarif
```

### Expected Findings

The test project contains intentional issues:

- ❌ Unwrap abuse (panics on None)
- ❌ Unused variables
- ❌ Unreachable code
- ❌ Redundant clones
- ❌ Potential integer overflow
- ❌ Empty loops
- ❌ Unsafe array indexing

---

## 🎯 Best Practices

### 1. Regular Analysis

Run CodeQL analysis regularly:

- ✓ Before each release
- ✓ On pull requests (CI/CD)
- ✓ After dependency updates
- ✓ During security audits

### 2. Database Management

```bash
# Keep databases fresh
codeql database create --overwrite rust-db ...

# Clean old databases
rm -rf old-databases/

# Compress for archival
tar -czf rust-db.tar.gz rust-db/
```

### 3. Query Selection

Start with recommended suites:

1. Begin: `rust-security-and-quality.qls`
2. If too noisy: `rust-code-scanning.qls`
3. For deep audit: `rust-security-extended.qls`

### 4. CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: CodeQL Analysis

on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: rust
      
      - name: Build
        run: cargo build --all-targets
      
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v2
```

### 5. Performance Tips

For large Rust projects:

```bash
# Use more threads
--threads=$(nproc)

# Allocate sufficient RAM
--ram=$(($(free -m | awk '/^Mem:/{print $2}') * 80 / 100))

# Build in release mode for faster extraction
--command="cargo build --release"

# Exclude test code if not needed
# (in codeql-database.yml)
paths-ignore:
  - "tests/**"
  - "benches/**"
```

---

## 🔍 Troubleshooting

### Common Issues

#### Issue: "No Rust code found"

```text
Solution: Ensure source-root points to directory with Cargo.toml
Check: ls -la /path/to/project/Cargo.toml
```

#### Issue: Build fails during database creation

```text
Solution: Test build manually first
Run: cargo build
Fix any compilation errors, then retry database creation
```

#### Issue: Out of memory

```text
Solution: Reduce parallel jobs
Use: --threads=2 --ram=4096
Or: cargo build --jobs=2 (in --command)
```

#### Issue: Query suite not found

```text
Solution: Verify CodeQL repo is downloaded
Check: $CODEQL_HOME/codeql-repo/rust/ql/src/
Run: codeql pack download codeql/rust-queries
```

---

## 📚 Additional Resources

### Documentation

- [CodeQL for Rust](https://codeql.github.com/docs/codeql-language-guides/codeql-for-rust/)
- [Rust Query Reference](https://codeql.github.com/codeql-standard-libraries/rust/)
- [SARIF Specification](https://sarifweb.azurewebsites.net/)

### Query Development

- [Writing Queries for Rust](https://codeql.github.com/docs/writing-codeql-queries/)
- [Rust QL Library](https://github.com/github/codeql/tree/main/rust/ql/lib)

### Community

- [CodeQL Discussion Forum](https://github.com/github/codeql/discussions)
- [CodeQL Slack](https://codeql.slack.com)

---

## ⏭️ Next Steps

Now that you understand Rust setup:

1. **Try the Lab**: Work through `lab/04-rust-setup/`
2. **Analyze Your Code**: Run CodeQL on your own Rust projects
3. **Learn C++ Setup**: Continue to `05-cpp-cmake-setup.md`
4. **Explore Queries**: Study built-in queries in `06-built-in-queries.md`

---

## 🎓 Summary

You've learned:

- ✓ Rust-specific CodeQL requirements
- ✓ How to create CodeQL databases for Rust projects
- ✓ Running security and quality analyses
- ✓ Understanding SARIF output format
- ✓ Best practices for Rust analysis

**Key Takeaway**: CodeQL provides powerful static analysis for Rust, helping you find security vulnerabilities and code quality issues before they reach production. Regular analysis as part of your development workflow significantly improves code reliability.

---

*📝 Note: Keep your CodeQL CLI and libraries updated for the latest Rust support and query improvements.*
