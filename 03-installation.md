# ⚙️ Installing & Configuring CodeQL

## 🎯 Overview

This guide walks you through installing CodeQL CLI and setting up
the VS Code extension for query development. Choose the installation
method that best fits your workflow.

---

## 🚀 Quick Start with GitHub Codespaces (Recommended)

The fastest way to get started is using GitHub Codespaces, which
provides a pre-configured development environment in your browser.

### Launch Codespace

1. Navigate to this repository on GitHub
2. Click **Code** → **Codespaces** → **Create codespace on main**
3. Wait 2-3 minutes for the environment to build
4. You'll have a complete environment with:
   - C++ compiler and CMake
   - Rust toolchain
   - VS Code with CodeQL extension
   - All build tools

### Complete the Lab Exercises

Once your codespace is ready:

```bash
cd lab/03-installation
cat README.md  # Read the lab instructions
```

The lab will guide you through:

1. Installing CodeQL CLI
2. Cloning standard libraries
3. Configuring VS Code
4. Creating test databases
5. Running your first analyses

**💡 Tip**: The codespace is fully reproducible - you can delete it
and recreate anytime without affecting your local machine!

---

## 💻 Alternative: Local Installation

If you prefer to install CodeQL on your local machine, follow the
instructions below.

---

## 🖥️ System Requirements

### Minimum Requirements

- **OS**: Linux, macOS, or Windows
- **RAM**: 4GB (8GB+ recommended)
- **Disk**: 500MB for CLI + space for databases
- **CPU**: Modern multi-core processor

### Language-Specific Requirements

**For C++ Analysis:**

- Working C++ compiler (GCC, Clang, or MSVC)
- Build system (CMake, Make, etc.)
- Your project's dependencies

**For Rust Analysis:**

- Rust toolchain: `rustc` and `cargo`
- Rust version: 1.65.0 or later recommended
- codeql v2.22.1 include preview for rust support


---

## 📦 Installing CodeQL CLI

### Method 1: Download from GitHub (Recommended)

**Step 1: Download Latest Release**

Visit: <https://github.com/github/codeql-cli-binaries/releases>

Download the appropriate bundle for your OS:

- Linux: `codeql-linux64.zip`
- macOS: `codeql-osx64.zip`
- Windows: `codeql-win64.zip`

**Step 2: Extract the Bundle**

```bash
# Linux/macOS
unzip codeql-linux64.zip -d ~/codeql-home
cd ~/codeql-home/codeql

# Windows (PowerShell)
Expand-Archive codeql-win64.zip -DestinationPath C:\codeql-home
cd C:\codeql-home\codeql
```

**Step 3: Add to PATH**

```bash
# Linux/macOS (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/codeql-home/codeql:$PATH"

# Reload shell
source ~/.zshrc  # or ~/.bashrc

# Windows (add to System Environment Variables)
# Add C:\codeql-home\codeql to PATH
```

**Step 4: Verify Installation**

```bash
codeql --version
# Should output: CodeQL command-line toolchain release 2.x.x
```

### Method 2: Using Homebrew (macOS/Linux)

```bash
# Add GitHub tap
brew tap github/codeql

# Install CodeQL
brew install codeql

# Verify
codeql --version
```

### Method 3: Using GitHub Actions (CI/CD Only)

If you only need CodeQL in CI/CD, GitHub Actions provides it:

```yaml
- name: Initialize CodeQL
  uses: github/codeql-action/init@v2
  with:
    languages: cpp, rust
```

---

## 📚 Installing CodeQL Libraries

The standard query libraries contain built-in queries and utilities.

### Clone the CodeQL Repository

```bash
# Choose a location
cd ~/codeql-home

# Clone the repository
git clone https://github.com/github/codeql.git codeql-repo

# This gives you:
# - Standard libraries for all languages
# - Built-in queries
# - Examples and documentation
```

### Clone the Coding Standards Repository

For MISRA and CERT compliance checking, clone the official coding 
standards repository:

```bash
# Clone coding standards (MISRA & CERT queries)
cd ~/codeql-home
git clone https://github.com/github/codeql-coding-standards.git \
  coding-standards

# This gives you:
# - MISRA C:2012 queries
# - MISRA C++:2023 queries  
# - CERT C queries
# - CERT C++ queries
# - Compliance query suites
```

**Why separate repository?**

The coding standards queries are maintained separately because:
- They follow external standards (MISRA, CERT)
- Have their own release cycle
- Require specific documentation and licensing

### Install Pack Dependencies

After cloning the coding standards repository, you need to install
the query pack dependencies:

```bash
# Install MISRA C++ dependencies
cd ~/codeql-home/coding-standards/cpp/misra/src
codeql pack install

# Install CERT C++ dependencies
cd ~/codeql-home/coding-standards/cpp/cert/src
codeql pack install
```

**What does `codeql pack install` do?**

- Downloads required CodeQL library packs (e.g., `codeql/cpp-all`)
- Installs dependencies specified in `qlpack.yml`
- Caches packages in `~/.codeql/packages`
- Required before running MISRA/CERT queries

**Common packages installed:**
- `codeql/cpp-all` - C++ standard library
- `codeql/dataflow` - Data flow analysis
- `codeql/util` - Utility functions
- `codeql/tutorial` - Tutorial helpers

### Directory Structure

```txt
~/codeql-home/
├── codeql/                  # CLI binaries
│   ├── codeql               # Main executable
│   └── ...
├── codeql-repo/             # Standard libraries and queries
│   ├── cpp/                 # C++ queries and libraries
│   ├── rust/                # Rust queries and libraries
│   ├── python/              # Python queries and libraries
│   └── ...
└── coding-standards/        # MISRA & CERT compliance queries
    ├── cpp/                 # C/C++ coding standards
    │   ├── misra/           # MISRA C and C++ queries
    │   └── cert/            # CERT C and C++ queries
    ├── docs/                # Standards documentation
    └── qlpacks/             # Query pack definitions
```

---

## 🔧 VS Code Extension Setup

The CodeQL extension provides IDE features for query development.

### Installation

**Step 1: Install VS Code**

Download from: <https://code.visualstudio.com/>

**Step 2: Install CodeQL Extension**

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X / Cmd+Shift+X)
3. Search for "CodeQL"
4. Install "CodeQL" by GitHub

Or via command line:

```bash
code --install-extension GitHub.vscode-codeql
```

### Configuration

**Step 1: Configure CLI Path**

Open VS Code settings (Ctrl+, / Cmd+,)

Search for "CodeQL" and configure:

```json
{
  "codeQL.cli.executablePath": 
    "/home/your-username/codeql-home/codeql/codeql",
  
  "codeQL.runningQueries.numberOfThreads": 0,
  
  "codeQL.runningQueries.memory": 8192
}
```

**Step 2: Set Query Library Path**

```json
{
  "codeQL.cli.searchPath": [
    "/home/your-username/codeql-home/codeql-repo"
  ]
}
```

**Step 3: Restart VS Code**

Close and reopen VS Code to apply settings.

### Verify Extension Setup

1. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Type "CodeQL: Check Installation"
3. Should show ✓ CLI found, ✓ Libraries found

---

## 🔍 Basic Configuration

### Create a CodeQL Workspace

For query development, create a workspace structure:

```bash
mkdir ~/my-codeql-workspace
cd ~/my-codeql-workspace

# Create directories
mkdir -p databases queries results

# Structure:
# databases/  - CodeQL databases for your projects
# queries/    - Your custom queries
# results/    - Query results (SARIF, CSV, etc.)
```

### Configure Search Paths

Create `codeql-workspace.yml`:

```yaml
name: My CodeQL Workspace

# Search paths for libraries
libraryPathDependencies:
  - /home/your-username/codeql-home/codeql-repo

# Additional query directories
additionalPacks:
  - ./queries
```

---

## 🧪 Testing Your Installation

### Test 1: Check CLI

```bash
# Get version
codeql version

# Get help
codeql --help

# List available languages
codeql resolve languages
```

Expected output should include: `cpp`, `rust`, and others.

### Test 2: Create a Test Database

**For C++:**

```bash
# Create a simple C++ file
mkdir -p /tmp/test-cpp
cat > /tmp/test-cpp/test.cpp << 'EOF'
#include <iostream>

int main() {
    std::cout << "Hello, CodeQL!" << std::endl;
    return 0;
}
EOF

# Create CodeQL database
codeql database create /tmp/test-cpp-db \
  --language=cpp \
  --threads=0 \
  --command="g++ test.cpp -o test" \
  --source-root=/tmp/test-cpp

# Should complete successfully
```

**For Rust:**

```bash
# Create a simple Rust project
cargo new /tmp/test-rust
cd /tmp/test-rust

# Create CodeQL database
codeql database create /tmp/test-rust-db \
  --language=rust \
  --threads=0 \
  --source-root=.

# Should complete successfully
```

### Test 3: Run a Built-in Query

```bash
# Using the C++ database
codeql database analyze /tmp/test-cpp-db \
  ~/codeql-home/codeql-repo/cpp/ql/src/codeql-suites/cpp-security-extended.qls \
  --format=sarif-latest \
  --threads=0 \
  --output=/tmp/results.sarif

# View results
cat /tmp/results.sarif
```

---

## 🎨 VS Code Extension Features

### Query Editor

**Syntax Highlighting**

- QL syntax highlighting
- Auto-completion for predicates
- Hover documentation

**Quick Actions**

- Right-click → "CodeQL: Run Query"
- View results inline
- Jump to source locations

### Database Management

**Import Database**

1. Command Palette → "CodeQL: Add Database from Archive"
2. Select `.zip` file of CodeQL database
3. Database appears in CodeQL view

**Database Explorer**

- Browse database schema
- View available predicates
- Explore relationships

### Query Results

**Results Panel**

- Table view of results
- Source location links
- Path visualization for data flow

**Export Options**

- Export as SARIF
- Export as CSV
- Copy to clipboard

---

## 🔧 Advanced Configuration

### Performance Tuning

**Memory Settings** (`~/.config/codeql/config`):

```yaml
# Allocate more memory for queries
runningQueries:
  memory: 16384  # MB

# Use more CPU cores
runningQueries:
  numberOfThreads: 8

# Cache settings
caching:
  maxDiskCache: 10240  # MB
```

### Custom Extractor Configuration

**C++ Specific** (`.codeqlconfig`):

```yaml
name: my-cpp-config

# Additional include paths
cpp:
  compiler:
    extraIncludes:
      - /usr/local/include
      - /opt/custom/include
  
  # Preprocessor definitions
  defines:
    - MY_DEFINE=1
    - DEBUG
```

**Rust Specific**:

```yaml
name: my-rust-config

rust:
  # Cargo features to enable
  features:
    - feature1
    - feature2
  
  # Target specification
  target: x86_64-unknown-linux-gnu
```

### Path Filters

Exclude paths from analysis:

```yaml
paths-ignore:
  - '**/test/**'
  - '**/build/**'
  - '**/third-party/**'
  - '**/*.test.cpp'

paths:
  - 'src/**'
  - 'include/**'
```

---

## 🐛 Troubleshooting

### CLI Not Found

**Symptom**: `codeql: command not found`

**Solution**:

```bash
# Verify PATH
echo $PATH

# Re-add to PATH
export PATH="$HOME/codeql-home/codeql:$PATH"

# Make permanent
echo 'export PATH="$HOME/codeql-home/codeql:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### VS Code Extension Issues

**Symptom**: Extension can't find CLI

**Solution**:

1. Check `codeQL.cli.executablePath` in settings
2. Use absolute path, not `~`
3. Restart VS Code
4. Run "CodeQL: Check Installation" command

### Database Creation Fails

**For C++:**

**Symptom**: "No commands were executed"

**Solution**:

```bash
# Ensure your build command actually compiles
# Use verbose build to verify:
codeql database create db --language=cpp \
  --command="make clean && make" \
  --source-root=. \
  --threads=0 \
  --verbose
```

**For Rust:**

**Symptom**: "cargo failed"

**Solution**:

```bash
# Ensure project builds first
cargo build

# Then create database
codeql database create db --language=rust \
  --source-root=. \
  --threads=0
```

### Out of Memory

**Symptom**: Query fails with OOM

**Solution**:

```bash
# Increase memory limit
codeql query run --ram=16384 query.ql

# Or in VS Code settings:
"codeQL.runningQueries.memory": 16384
```

---

## ⚡ Performance Optimization

### Multi-core Usage

**Recommended**: Always use `--threads=0` to utilize all CPU cores:

```bash
# Database creation
codeql database create db \
  --language=cpp \
  --threads=0 \
  --command="ninja"

# Analysis
codeql database analyze db \
  query-suite.qls \
  --threads=0 \
  --output=results.sarif
```

**Why `--threads=0`?**
- `0` = Use all available CPU cores automatically
- `N` = Use exactly N threads
- `-N` = Use all cores minus N (leave N cores free)
- Default is `1` (single-threaded) which is very slow

### Precompiled Queries

If the git repo for coding standards is directly cloned, all queries must be
first compiled and will be stored in a rules cache. This compilation is terribly
slow (even with --threads=0) as it is limited to use just a single core.

The modern approach is to not use this rules cache, but to compile `.qlx` files
instead like so:

```bash
# 1. Precompile queries to .qlx files
codeql query compile \
  --precompile \
  --threads=0 \
  codeql/misra-cpp-coding-standards

# 2. Use precompiled queries with special flag
codeql database analyze db \
  path/to/precompiled.qlx \
  --expect-discarded-cache \
  --threads=0 \
  --output=results.sarif
```

**Note**: The `--expect-discarded-cache` flag is required when using
precompiled `.qlx` files to avoid cache-related errors.

---

## ✅ Installation Checklist

Before proceeding to language-specific guides:

- [ ] CodeQL CLI installed and in PATH
- [ ] CodeQL version checked: `codeql --version`
- [ ] Standard query libraries cloned
- [ ] VS Code with CodeQL extension installed
- [ ] Extension configured with CLI path
- [ ] Test database created successfully
- [ ] Test query executed successfully

**💡 Using Codespaces?** Run the verification script:

```bash
cd lab/03-installation
./verify-setup.sh
```

---

## 📚 Next Steps

### Hands-On Learning (Recommended)

Complete the interactive lab exercises:

- 🧪 **[Lab 03: Installation](lab/03-installation/README.md)** - 
  Hands-on installation and testing

### Language-Specific Guides

- 🦀 **[Rust Setup](04-rust-setup.md)** - Configure CodeQL for
  Rust projects
- 🔧 **[C++/CMake Setup](05-cpp-cmake-setup.md)** - Configure
  CodeQL for C++/CMake projects

### Using CodeQL

- 🔍 **[Built-in Queries](06-built-in-queries.md)** - Start using
  out-of-the-box queries

---

## 🔗 Useful Links

- [CodeQL CLI Setup](https://codeql.github.com/docs/codeql-cli/getting-started-with-the-codeql-cli/)
- [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-codeql)
- [CodeQL Downloads](https://github.com/github/codeql-cli-binaries/releases)
- [Query Libraries](https://github.com/github/codeql)
- [GitHub Codespaces](https://github.com/features/codespaces)
