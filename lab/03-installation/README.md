# 🧪 Lab 03: Installing & Configuring CodeQL

## 🎯 Learning Objectives

By the end of this lab, you will:

- Install the CodeQL CLI from GitHub releases
- Clone and configure the CodeQL standard libraries
- Configure the VS Code CodeQL extension
- Create your first CodeQL databases for C++ and Rust
- Run built-in queries and view SARIF results
- Verify your installation with test projects

---

## ⏱️ Estimated Time

- **Core exercises**: 30-45 minutes
- **Optional challenges**: 15-30 minutes

---

## 📋 Prerequisites

- GitHub Codespace (recommended) or local environment with:
  - C++ compiler (GCC or Clang)
  - CMake and build tools
  - Rust toolchain (rustc, cargo)
  - VS Code

---

## 🚀 Getting Started

### Option A: Using GitHub Codespaces (Recommended)

1. Click "Code" → "Create codespace on main"
2. Wait for the environment to build (~2-3 minutes)
3. You'll have a ready environment with all dependencies!

### Option B: Local Environment

Ensure you have:

- C++ compiler, CMake, Ninja (or Make)
- Rust toolchain: `curl --proto '=https' --tlsv1.2 -sSf
  https://sh.rustup.rs | sh`
- VS Code with Remote Development extensions

---

## 📚 Exercise 1: Install CodeQL CLI

Follow the guided installation script:

```bash
cd lab/03-installation
./install-codeql.sh
```

This script will:

1. Download the latest CodeQL CLI from GitHub
2. Extract it to `~/.codeql-home/codeql`
3. Add CodeQL to your PATH
4. Verify the installation

**✅ Verification:**

```bash
codeql --version
# Expected: CodeQL command-line toolchain release 2.x.x
```

**💡 Alternative: Manual Installation**

If you prefer manual steps, see: `MANUAL_INSTALL.md`

---

## 📚 Exercise 2: Install Standard Libraries

Clone the CodeQL standard query libraries:

```bash
./install-libraries.sh
```

This will:

1. Clone `github/codeql` repository
2. Place it in `~/.codeql-home/codeql-repo`
3. Give you access to built-in queries for all languages

**✅ Verification:**

```bash
ls ~/.codeql-home/codeql-repo
# Expected: cpp/ rust/ python/ java/ javascript/ ...
```

---

## 🔧 Exercise 3: Configure VS Code Extension

The CodeQL extension should already be installed in your codespace.

Now configure it:

```bash
./configure-vscode.sh
```

This script:

1. Sets the CodeQL CLI path in VS Code settings
2. Configures the search path for libraries
3. Sets performance parameters (RAM, threads)

**✅ Verification:**

1. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Run: "CodeQL: Check Installation"
3. Should show: ✓ CLI found, ✓ Libraries found

---

## 🧪 Exercise 4: Test with C++ Project

Test your setup with a small C++ project.

**Step 1: Explore the test project**

```bash
cd test-cpp-project
cat README.md
```

This project has intentional security issues for CodeQL to find:

- Buffer overflow risk
- Use of unsafe functions
- Potential null pointer dereference

**Step 2: Build the project**

```bash
mkdir build
cd build
cmake .. -G Ninja
ninja
cd ..
```

**Step 3: Create CodeQL database**

```bash
cd ..
./create-cpp-database.sh
```

This will:

1. Create a CodeQL database from the C++ project
2. Store it in `databases/test-cpp-db`

**Step 4: Run security queries**

```bash
./analyze-cpp-database.sh
```

This runs the C++ security query suite and outputs SARIF results.

**Step 5: View results**

```bash
cat results/cpp-results.sarif | jq '.runs[0].results | length'
# Shows number of findings

# View in VS Code:
code results/cpp-results.sarif
```

**✅ Expected Findings:**

- Use of dangerous function (strcpy)
- Potential buffer overflow
- Missing bounds check

---

## 🦀 Exercise 5: Test with Rust Project

Test your setup with a Rust project.

**Step 1: Explore the test project**

```bash
cd test-rust-project
cat README.md
```

This project has patterns CodeQL can detect:

- Unused variables
- Unreachable code
- Potential panic situations

**Step 2: Build the project**

```bash
cargo build
cd ..
```

**Step 3: Create CodeQL database**

```bash
./create-rust-database.sh
```

**Step 4: Run quality queries**

```bash
./analyze-rust-database.sh
```

**Step 5: View results**

```bash
cat results/rust-results.sarif | jq
code results/rust-results.sarif
```

**✅ Expected Findings:**

- Unused variables
- Unreachable code patterns
- Code quality suggestions

---

## ✅ Exercise 6: Verify Complete Setup

Run the complete verification script:

```bash
cd lab/03-installation
./verify-setup.sh
```

This checks:

- ✓ CodeQL CLI installed and in PATH
- ✓ Correct version
- ✓ Standard libraries present
- ✓ VS Code extension configured
- ✓ Can create C++ database
- ✓ Can create Rust database
- ✓ Can run queries

Expected output: All checks pass with ✓

---

## 🌟 Challenge 1: Analyze Real Open-Source Projects

Try analyzing well-maintained, moderately-sized projects:

### Recommended C++ Projects

**1. JSON for Modern C++ (nlohmann/json)**

- Size: ~30K lines of C++
- Well-maintained, high quality code
- Good for learning what "clean" code looks like in CodeQL

```bash
cd ~/projects
git clone https://github.com/nlohmann/json.git
cd json

# Create database
codeql database create ../json-db \
  --language=cpp \
  --command="cmake -S . -B build && cmake --build build" \
  --source-root=.

# Analyze
codeql database analyze ../json-db \
  ~/.codeql-home/codeql-repo/cpp/ql/src/codeql-suites/cpp-security-extended.qls \
  --format=sarif-latest \
  --output=../json-results.sarif
```

**2. spdlog (gabime/spdlog)**

- Size: ~10K lines of C++
- Fast C++ logging library
- Header-only, easier to analyze

```bash
git clone https://github.com/gabime/spdlog.git
cd spdlog
codeql database create ../spdlog-db \
  --language=cpp \
  --command="cmake -S . -B build && cmake --build build" \
  --source-root=.
```

### Recommended Rust Projects

**1. ripgrep (BurntSushi/ripgrep)**

- Size: ~25K lines of Rust
- Fast search tool (like grep)
- Excellent code quality

```bash
cd ~/projects
git clone https://github.com/BurntSushi/ripgrep.git
cd ripgrep

# Create database
codeql database create ../ripgrep-db \
  --language=rust \
  --source-root=.

# Analyze
codeql database analyze ../ripgrep-db \
  ~/.codeql-home/codeql-repo/rust/ql/src/codeql-suites/rust-security-and-quality.qls \
  --format=sarif-latest \
  --output=../ripgrep-results.sarif
```

**2. bat (sharkdp/bat)**

- Size: ~8K lines of Rust
- Cat clone with syntax highlighting
- Clean, well-structured code

```bash
git clone https://github.com/sharkdp/bat.git
cd bat
codeql database create ../bat-db \
  --language=rust \
  --source-root=.
```

**💡 Analysis Tips:**

- Compare findings between projects
- Notice how high-quality projects have fewer issues
- Look at the types of patterns CodeQL finds
- Practice reading SARIF output

---

## 🌟 Challenge 2: Database Performance

Compare database creation times and sizes:

```bash
# Check your test databases
du -sh databases/*

# Time database creation
time codeql database create test-db --language=cpp --command="..."

# Experiment with threads
codeql database create test-db --threads=4 ...
```

**Questions to explore:**

- How does database size relate to source code size?
- How many CPU cores does CodeQL use?
- What's stored in the database?

---

## 🌟 Challenge 3: Query Exploration

Explore the standard query libraries:

```bash
cd ~/.codeql-home/codeql-repo/cpp/ql/src

# Browse available queries
tree -L 3

# Look at security queries
ls Security/CWE/

# Read a simple query
cat Security/CWE/CWE-120/UnboundedWrite.ql
```

Try running individual queries instead of full suites.

---

## 📝 Lab Checklist

- [ ] CodeQL CLI installed and working
- [ ] Standard libraries cloned
- [ ] VS Code extension configured
- [ ] Created C++ test database successfully
- [ ] Ran C++ security queries
- [ ] Viewed SARIF results
- [ ] Created Rust test database successfully
- [ ] Ran Rust quality queries
- [ ] All verification checks pass
- [ ] (Optional) Analyzed an open-source C++ project
- [ ] (Optional) Analyzed an open-source Rust project

---

## 🐛 Troubleshooting

### CLI not found after installation

```bash
# Reload shell configuration
source ~/.zshrc

# Or manually add to PATH
export PATH="$HOME/.codeql-home/codeql:$PATH"
```

### Database creation fails

```bash
# Check verbose output
codeql database create db --language=cpp \
  --command="..." \
  --verbose

# For C++: ensure project builds first
cmake --build build  # test this works

# For Rust: ensure cargo build works
cargo build  # test this works
```

### Out of memory

```bash
# Increase RAM limit
codeql database analyze db query.qls --ram=8192
```

### Need help?

- Check `TROUBLESHOOTING.md` in this directory
- Review `03-installation.md` in the root
- Check CodeQL logs in database `log/` directory

---

## 📚 Next Steps

Once you've completed this lab:

- 🦀 **[Lab 04: Rust Setup](../04-rust-setup/)** - Deep dive into
  Rust-specific features
- 🔧 **[Lab 05: C++/CMake Setup](../05-cpp-cmake-setup/)** -
  Advanced C++ analysis
- 🔍 **[Lab 06: Built-in Queries](../06-built-in-queries/)** -
  Explore query suites

---

## 🔗 Resources

- [CodeQL CLI Documentation](https://codeql.github.com/docs/codeql-cli/)
- [Standard Libraries](https://github.com/github/codeql)
- [SARIF Specification](https://sarifweb.azurewebsites.net/)
