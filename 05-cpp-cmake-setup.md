# 🔧 C++ and CMake Setup for CodeQL

## 📖 Overview

This guide covers everything you need to know to use CodeQL with C++
projects, focusing on CMake-based builds. Learn how to create
databases, analyze code, and interpret security findings.

---

## 🎯 What You'll Learn

- C++-specific requirements for CodeQL
- Creating CodeQL databases for C++ projects
- CMake integration and build system support
- Running built-in security and quality queries
- Understanding SARIF output format
- Best practices for C++ analysis

---

## ✅ Prerequisites

Before starting with C++ analysis, ensure you have:

- ✓ CodeQL CLI installed (see `03-installation.md`)
- ✓ C++ compiler installed (GCC, Clang, or MSVC)
- ✓ CMake 3.10 or later
- ✓ Build tools (Make, Ninja, or MSBuild)
- ✓ CodeQL standard libraries downloaded
- ✓ A C++ project to analyze (or use our test project)

Check your installation:

```bash
g++ --version    # or clang++ --version
cmake --version
ninja --version  # or make --version
```

---

## 🔧 C++-Specific Requirements

### Language Support

CodeQL has **full support** for C++, including:

- **Language versions**: C++98 through C++23
- **Compilers**: GCC, Clang, MSVC, Intel C++
- **Build systems**: CMake, Make, Ninja, MSBuild, Bazel
- **Platforms**: Linux, macOS, Windows
- **Standards**: Full C++ standard library support

### System Resources

For typical C++ projects:

- **RAM**: 8-16 GB minimum (32 GB recommended for large projects)
- **Disk**: 1-10 GB per database (varies by project size)
- **CPU**: Multi-core strongly recommended for faster analysis

**Note**: C++ databases are typically larger than other languages due
to the complexity of the language and extensive standard library.

### Compiler Configuration

CodeQL works with any standard C++ compiler. For best results:

```bash
# GCC (Linux)
sudo apt-get install build-essential cmake ninja-build

# Clang (Linux)
sudo apt-get install clang cmake ninja-build

# macOS (using Homebrew)
brew install cmake ninja

# Verify installation
cmake --version
g++ --version
```

---

## 🗄️ Creating CodeQL Databases for C++

### Basic Database Creation

A CodeQL database captures your C++ project's structure, including
all header dependencies and preprocessor expansions.

**Command Syntax:**

```bash
codeql database create <database-path> \
    --language=cpp \
    --source-root=<project-path> \
    --command="<build-command>"
```

**Parameters:**

- `<database-path>`: Where to store the database (e.g., `./cpp-db`)
- `--language=cpp`: Specifies C++ as the target language
- `--source-root=<path>`: Root directory of your C++ project
- `--command="..."`: Your project's build command

### Example: CMake Project

For a typical CMake project:

```bash
codeql database create cpp-db \
    --language=cpp \
    --source-root=./my-cpp-project \
    --command="cmake -B build -G Ninja && ninja -C build"
```

This command:

1. 🔍 Monitors the build process
2. 🔨 Executes CMake configuration and Ninja build
3. 📊 Extracts semantic information from compilation
4. 💾 Stores everything in `cpp-db/`

### Step-by-Step CMake Build

For better control, separate CMake configuration and build:

```bash
# Configure CMake first (outside CodeQL)
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug

# Create database with clean build
codeql database create cpp-db \
    --language=cpp \
    --source-root=. \
    --command="ninja -C build clean && ninja -C build"
```

### Example: Make Projects

For traditional Make-based projects:

```bash
codeql database create cpp-db \
    --language=cpp \
    --source-root=./my-project \
    --command="make clean && make -j$(nproc)"
```

### Build System Variations

**Visual Studio / MSBuild (Windows):**

```bash
codeql database create cpp-db ^
    --language=cpp ^
    --source-root=. ^
    --command="msbuild /t:Rebuild /p:Configuration=Debug"
```

**Bazel:**

```bash
codeql database create cpp-db \
    --language=cpp \
    --source-root=. \
    --command="bazel clean && bazel build //..."
```

**Autotools:**

```bash
codeql database create cpp-db \
    --language=cpp \
    --source-root=. \
    --command="./configure && make clean && make -j$(nproc)"
```

### Advanced Options

**Threading and Performance:**

```bash
codeql database create cpp-db \
    --language=cpp \
    --source-root=. \
    --command="ninja -C build" \
    --threads=16 \
    --ram=16384
```

**Verbose Output:**

```bash
codeql database create cpp-db \
    --language=cpp \
    --source-root=. \
    --command="ninja -C build" \
    --verbose
```

**Working Directory:**

```bash
codeql database create cpp-db \
    --language=cpp \
    --source-root=. \
    --working-dir=./build \
    --command="ninja"
```

---

## ⚙️ CMake Integration

### CMake Best Practices for CodeQL

#### 1. Use Debug Build for Analysis

Debug builds provide better source location information:

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -G Ninja
```

#### 2. Generate Compile Commands

CMake can generate `compile_commands.json`:

```bash
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G Ninja
```

This file helps CodeQL understand your build configuration.

#### 3. Disable Compiler Caches

For reproducible analysis, disable ccache:

```bash
cmake -B build -DCMAKE_CXX_COMPILER_LAUNCHER="" -G Ninja
```

### CMakeLists.txt Configuration

No special CodeQL configuration needed in `CMakeLists.txt`, but
consider:

```cmake
# Good: Clear compiler flags
target_compile_options(myapp PRIVATE
    -Wall -Wextra -Wpedantic
)

# Good: Explicit include directories
target_include_directories(myapp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Good: Clear dependencies
target_link_libraries(myapp PRIVATE
    somelib
    pthread
)
```

### Multi-Target Projects

For projects with multiple targets:

```bash
# Build all targets
codeql database create cpp-db \
    --language=cpp \
    --source-root=. \
    --command="ninja -C build all"

# Or build specific targets
codeql database create cpp-db \
    --language=cpp \
    --source-root=. \
    --command="ninja -C build target1 target2"
```

---

## ⚙️ Configuration for C++ Projects

### Database Configuration

CodeQL can be configured via `codeql-database.yml` in your project
root:

```yaml
name: "my-cpp-project"
languages:
  - cpp
primaryLanguage: cpp
```

### Excluding Directories

To skip certain directories (e.g., third-party code):

```yaml
paths-ignore:
  - build/
  - external/
  - third-party/
  - tests/fixtures/
  - .cache/
```

### Include Path Filtering

Focus analysis on specific paths:

```yaml
paths:
  - src/
  - include/
```

### Custom Queries Configuration

Create `.codeqlmanifest.json` for query metadata:

```json
{
  "name": "my-cpp-queries",
  "version": "1.0.0",
  "dependencies": {
    "codeql/cpp-all": "*"
  }
}
```

---

## 🔍 Running Built-in Queries

### Available Query Suites

CodeQL provides several pre-built query suites for C++:

1. **`cpp-security-extended.qls`**
   - All security-related queries
   - Best for comprehensive security audits
   - Higher false positive rate

2. **`cpp-security-and-quality.qls`**
   - Security + code quality checks
   - **Recommended starting point**
   - Balanced precision/recall

3. **`cpp-code-scanning.qls`**
   - Optimized for GitHub Code Scanning
   - Lower false positives
   - Production-ready queries

### Running Analysis

**Basic Analysis:**

```bash
codeql database analyze cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-security-and-quality.qls \
    --format=sarif-latest \
    --output=results.sarif
```

**With Performance Options:**

```bash
codeql database analyze cpp-db \
    codeql/cpp-queries:codeql-suites/cpp-security-and-quality.qls \
    --format=sarif-latest \
    --output=results.sarif \
    --threads=16 \
    --ram=16384
```

### Query Suite Locations

If you cloned the CodeQL repository:

```bash
# Security and quality (recommended)
$CODEQL_HOME/codeql-repo/cpp/ql/src/codeql-suites/\
cpp-security-and-quality.qls

# Security extended
$CODEQL_HOME/codeql-repo/cpp/ql/src/codeql-suites/\
cpp-security-extended.qls

# Code scanning
$CODEQL_HOME/codeql-repo/cpp/ql/src/codeql-suites/\
cpp-code-scanning.qls
```

### Running Specific Queries

To run individual queries:

```bash
# Find buffer overflows
codeql database analyze cpp-db \
    $CODEQL_HOME/codeql-repo/cpp/ql/src/\
Security/CWE/CWE-119/BufferOverflow.ql \
    --format=sarif-latest \
    --output=buffer-overflow-results.sarif
```

---

## 📊 Understanding Query Results

### Common C++ Security Issues Detected

CodeQL for C++ can find:

| Category | Examples |
|----------|----------|
| **Memory Safety** | Buffer overflow, use-after-free, double-free |
| **Resource Management** | Memory leaks, file descriptor leaks |
| **Integer Issues** | Overflow, underflow, signedness errors |
| **Pointer Issues** | Null dereference, dangling pointers |
| **Injection** | Command injection, SQL injection |
| **Concurrency** | Data races, deadlocks |
| **Cryptography** | Weak algorithms, insecure random |

### Example Findings

**Buffer Overflow:**

```cpp
// 🚨 CodeQL will flag this
void vulnerable(const char* input) {
    char buffer[32];
    strcpy(buffer, input);  // No bounds check!
}

// ✅ Better approach
void safe(const char* input) {
    char buffer[32];
    strncpy(buffer, input, sizeof(buffer) - 1);
    buffer[sizeof(buffer) - 1] = '\0';
}
```

**Use After Free:**

```cpp
// 🚨 Dangerous
int* create_and_free() {
    int* p = new int(42);
    delete p;
    return p;  // Returning freed memory!
}

// ✅ Correct
std::unique_ptr<int> create() {
    return std::make_unique<int>(42);
}
```

**Null Pointer Dereference:**

```cpp
// 🚨 CodeQL detects this
void process(int* ptr) {
    *ptr = 42;  // No null check!
}

// ✅ Safe version
void process(int* ptr) {
    if (ptr) {
        *ptr = 42;
    }
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
          "ruleId": "cpp/buffer-overflow",
          "message": { "text": "..." },
          "locations": [ ... ],
          "level": "error"
        }
      ]
    }
  ]
}
```

### Key SARIF Elements

**Result Object:**

- `ruleId`: Unique identifier for the query (e.g., `cpp/buffer-overflow`)
- `message`: Human-readable description
- `locations`: Source code locations
- `level`: Severity (error, warning, note)
- `relatedLocations`: Additional context
- `codeFlows`: Data flow paths for taint tracking

**Location Object:**

```json
{
  "physicalLocation": {
    "artifactLocation": {
      "uri": "src/vulnerable.cpp"
    },
    "region": {
      "startLine": 15,
      "endLine": 15,
      "startColumn": 5,
      "endColumn": 20
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

Open any `.sarif` file in VS Code for interactive viewing with
source navigation.

**2. Command-line with `jq`:**

```bash
# Count total results
jq '.runs[0].results | length' results.sarif

# List all rule IDs
jq '.runs[0].results[].ruleId' results.sarif | sort | uniq

# Show error-level findings
jq '.runs[0].results[] | select(.level == "error")' results.sarif

# Extract messages with locations
jq -r '.runs[0].results[] | 
    "\(.ruleId): \(.message.text) at \
    \(.locations[0].physicalLocation.artifactLocation.uri):\
    \(.locations[0].physicalLocation.region.startLine)"' \
    results.sarif
```

**3. GitHub Code Scanning:**

Upload SARIF to GitHub for integrated viewing:

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

# Include source code snippets
--sarif-add-snippets

# Add file coverage information
--sarif-add-file-coverage
```

### Other Output Formats

Besides SARIF, CodeQL supports:

**CSV Format:**

```bash
codeql database analyze cpp-db queries.qls \
    --format=csv \
    --output=results.csv
```

**JSON (raw):**

```bash
--format=json
```

**GraphViz (for data flow paths):**

```bash
--format=dot
```

---

## 🧪 Hands-On Lab Exercise

A complete lab setup is available in `lab/05-cpp-cmake-setup/`:

### Lab Structure

```text
lab/05-cpp-cmake-setup/
├── create-cpp-database.sh       # Create test database
├── analyze-cpp-database.sh      # Run analysis
└── test-cpp-project/            # Sample C++ project
    ├── CMakeLists.txt           # CMake configuration
    ├── src/
    │   ├── main.cpp             # Main program
    │   ├── vulnerable.cpp       # Intentionally buggy code
    │   └── vulnerable.h         # Header file
    └── build/                   # Build directory
```

### Running the Lab

#### Step 1: Create the database

```bash
cd lab/05-cpp-cmake-setup
./create-cpp-database.sh
```

This configures CMake, builds the test project, and creates a CodeQL
database.

#### Step 2: Run the analysis

```bash
./analyze-cpp-database.sh
```

This analyzes the database and generates SARIF output.

#### Step 3: Review results

```bash
# View with jq
jq -r '.runs[0].results[] | 
    "\(.ruleId): \(.message.text) at \
    \(.locations[0].physicalLocation.artifactLocation.uri):\
    \(.locations[0].physicalLocation.region.startLine)"' \
    results/cpp-results.sarif

# Or open in VS Code
code results/cpp-results.sarif
```

### Expected Findings

The test project contains intentional vulnerabilities:

- ❌ **CWE-120**: Buffer overflow (unsafe `strcpy`)
- ❌ **CWE-476**: Null pointer dereference
- ❌ **CWE-401**: Memory leak
- ❌ **CWE-416**: Use after free
- ❌ **CWE-190**: Integer overflow
- ❌ **CWE-78**: Command injection

---

## 🎯 Best Practices

### 1. Regular Analysis

Run CodeQL analysis regularly:

- ✓ Before each release
- ✓ On pull requests (CI/CD)
- ✓ After dependency updates
- ✓ During security audits
- ✓ After refactoring sessions

### 2. Database Management

```bash
# Always build clean for analysis
cmake -B build -G Ninja && ninja -C build clean

# Keep databases fresh
codeql database create --overwrite cpp-db ...

# Clean old databases
rm -rf old-databases/

# Compress for archival
tar -czf cpp-db.tar.gz cpp-db/
```

### 3. Query Selection

Start with recommended suites:

1. Begin: `cpp-security-and-quality.qls`
2. If too noisy: `cpp-code-scanning.qls`
3. For deep audit: `cpp-security-extended.qls`

### 4. Build Configuration

For best CodeQL results:

```cmake
# Use Debug build
cmake -DCMAKE_BUILD_TYPE=Debug

# Enable all warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")

# Generate compile commands
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Disable precompiled headers (can interfere)
set(CMAKE_DISABLE_PRECOMPILE_HEADERS ON)
```

### 5. CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: CodeQL Analysis

on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y cmake ninja-build
      
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: cpp
      
      - name: Build
        run: |
          cmake -B build -G Ninja
          ninja -C build
      
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v2
```

### 6. Performance Tips

For large C++ projects:

```bash
# Use all available cores
--threads=$(nproc)

# Allocate 80% of available RAM
--ram=$(($(free -m | awk '/^Mem:/{print $2}') * 80 / 100))

# Use Ninja for faster builds
cmake -G Ninja

# Parallel build
ninja -j$(nproc)

# Exclude test code if not needed
paths-ignore:
  - "test/**"
  - "tests/**"
  - "benchmark/**"
```

---

## 🔍 Troubleshooting

### Common Issues

#### Issue: "No C++ code found"

```text
Solution: Ensure build command actually compiles code
Check: Run build command manually and verify .o files created
Verify: --source-root points to directory with source files
```

#### Issue: Build fails during database creation

```text
Solution: Test build manually first
Run: cmake -B build -G Ninja && ninja -C build
Fix any compilation errors, then retry database creation
```

#### Issue: Out of memory

```text
Solution: Reduce parallel jobs and allocate more RAM
Use: --threads=4 --ram=8192
CMake: cmake -DCMAKE_BUILD_PARALLEL_LEVEL=4
Ninja: ninja -j4
```

#### Issue: Missing header files

```text
Solution: Ensure all dependencies are installed
Check: CMake configuration succeeds
Verify: include paths are correct in CMakeLists.txt
```

#### Issue: Incomplete database

```text
Solution: Use clean build
Run: ninja clean before creating database
Or: cmake --build build --target clean
```

#### Issue: Query suite not found

```text
Solution: Verify CodeQL repo is downloaded
Check: $CODEQL_HOME/codeql-repo/cpp/ql/src/
Run: codeql pack download codeql/cpp-queries
```

---

## 📚 Additional Resources

### Documentation

- [CodeQL for C++](https://codeql.github.com/docs/codeql-language-guides/codeql-for-cpp/)
- [C++ Query Reference](https://codeql.github.com/codeql-standard-libraries/cpp/)
- [CMake Documentation](https://cmake.org/documentation/)
- [SARIF Specification](https://sarifweb.azurewebsites.net/)

### Query Development

- [Writing Queries for C++](https://codeql.github.com/docs/writing-codeql-queries/)
- [C++ QL Library](https://github.com/github/codeql/tree/main/cpp/ql/lib)
- [CWE Coverage](https://codeql.github.com/codeql-query-help/cpp/)

### Security Standards

- [CWE - Common Weakness Enumeration](https://cwe.mitre.org/)
- [CERT C++ Coding Standard](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)
- [MISRA C++ Guidelines](https://www.misra.org.uk/)

### Community

- [CodeQL Discussion Forum](https://github.com/github/codeql/discussions)
- [CodeQL Slack](https://codeql.slack.com)
- [Stack Overflow - CodeQL](https://stackoverflow.com/questions/tagged/codeql)

---

## ⏭️ Next Steps

Now that you understand C++ and CMake setup:

1. **Try the Lab**: Work through `lab/05-cpp-cmake-setup/`
2. **Analyze Your Code**: Run CodeQL on your own C++ projects
3. **Explore Queries**: Study built-in queries
4. **Learn Standards**: Continue to coding standards documentation

---

## 🎓 Summary

You've learned:

- ✓ C++-specific CodeQL requirements
- ✓ How to create CodeQL databases for C++ projects
- ✓ CMake integration and build system support
- ✓ Running security and quality analyses
- ✓ Understanding SARIF output format
- ✓ Best practices for C++ analysis

**Key Takeaway**: CodeQL provides comprehensive static analysis for
C++, helping you find memory safety issues, buffer overflows, and
other critical vulnerabilities before they reach production. The
integration with CMake makes it easy to incorporate into modern C++
development workflows.

---

*📝 Note: Keep your CodeQL CLI and libraries updated for the latest
C++ support and query improvements. C++ analysis benefits greatly
from regular updates due to evolving language standards.*
