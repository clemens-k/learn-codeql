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
./install-codeql.sh v2.20.7
```

This script will:

1. Download the v2.20.7 CodeQL CLI from GitHub, if you leave the version out,
   the latest version will be downloaded
2. Extract it to `~/.codeql-home/codeql`
3. Add CodeQL to your PATH
4. Verify the installation

**✅ Verification:**

```bash
codeql --version
# Expected: CodeQL command-line toolchain release 2.x.x
```

---

## 📚 Exercise 2: Install Standard Libraries

Install the CodeQL coding standards:

```bash
./install-libraries.sh v2.51.0
```

This will:

1. Download all release assets from `github/codeql-coding-standards` (MISRA & CERT)
2. Extract the CodeQL packs (coding-standards-cpp-query-pack.zip)
3. Keep all other assets (documentation, checksums, etc.) for reference
4. Place everything in `~/.codeql-home/coding-standards/`

**Note:** The CodeQL bundle already includes the standard libraries for all languages, 
so we only need to install the coding standards separately.

**What gets installed:**

- **coding-standards**: MISRA C++:2023 and CERT C++ compliance queries (extracted)
- **Documentation**: User manual, supported rules list, certification kit
- **Metadata**: Checksums and other release assets
- **Pack dependencies**: Required libraries (cpp-all, dataflow, util, etc.)

**✅ Verification:**

```bash
ls ~/.codeql-home/coding-standards/
# Expected: codeql-coding-standards-* directories plus .zip, .md, .csv files
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

## ✅ Exercise 4: Verify Complete Setup

Run the complete verification script:

```bash
cd lab/03-installation
./verify-setup.sh
```

This checks:

- ✓ CodeQL CLI installed and in PATH
- ✓ Correct version
- ✓ Standard libraries present
- ✓ Coding standards (MISRA & CERT) present
- ✓ VS Code extension configured
- ✓ Can create C++ database
- ✓ Can create Rust database
- ✓ Can run queries

Expected output: All checks pass with ✓


## 🐛 Troubleshooting

### CLI not found after installation

```bash
# Reload shell configuration
source ~/.zshrc

# Or manually add to PATH
export PATH="$HOME/.codeql-home/codeql:$PATH"
```
---

## 📚 Next Steps

Once you've completed this lab:

- 🦀 **[Lab 04: Rust Setup](../04-rust-setup/)** - Deep dive into
  Rust-specific features
- 🔧 **[Lab 05: C++/CMake Setup](../05-cpp-cmake-setup/)** -
  C++ analysis
- 🔍 **[Lab 06: Built-in Queries](../06-built-in-queries/)** -
  Explore query suites

---

## 🔗 Resources

- [CodeQL CLI Documentation](https://codeql.github.com/docs/codeql-cli/)
- [Standard Libraries](https://github.com/github/codeql)
- [SARIF Specification](https://sarifweb.azurewebsites.net/)
