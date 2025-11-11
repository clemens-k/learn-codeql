# 📚 Learn CodeQL

A hands-on learning resource for understanding and using CodeQL, GitHub's
semantic code analysis engine. This repository provides comprehensive
tutorials and practical labs for analyzing code with CodeQL.

## 🎯 What You'll Learn

- **Introduction to CodeQL**: Understanding what CodeQL is and how it treats code as data
- **Architecture & Tech Stack**: How CodeQL works internally, from extraction to query execution
- **Installation & Configuration**: Setting up CodeQL CLI and VS Code extension
- **Practical Analysis**: Creating databases and running queries on real projects

## 📖 Course Content

### Tutorials

1. **[01-introduction.md](01-introduction.md)** - Introduction to CodeQL
   - What is CodeQL and how it works
   - Key concepts: code as data, declarative queries, static analysis
   - History and background of CodeQL/Semmle

2. **[02-architecture.md](02-architecture.md)** - CodeQL Architecture & Tech Stack
   - High-level architecture overview
   - The three phases: extraction, database creation, query execution
   - Core technologies and components

3. **[03-installation.md](03-installation.md)** - Installing & Configuring CodeQL
   - Quick start with GitHub Codespaces
   - Local installation guide
   - VS Code extension setup

4. **[04-rust-setup.md](04-rust-setup.md)** - Rust Setup for CodeQL
   - Rust-specific requirements for CodeQL
   - Creating CodeQL databases for Rust projects
   - Running security and quality queries
   - Understanding SARIF output format

### Hands-On Labs

#### Lab 03: Installation & Configuration

Located in `lab/03-installation/`, this lab covers the initial setup:

- **Automated Scripts**:
  - `install-codeql.sh` - Download and install CodeQL CLI
  - `install-libraries.sh` - Clone CodeQL standard libraries
  - `configure-vscode.sh` - Set up VS Code extension
  - `verify-setup.sh` - Verify complete installation

See `lab/03-installation/README.md` for detailed instructions.

#### Lab 04: Rust Setup for CodeQL

Located in `lab/04-rust-setup/`, this lab provides hands-on experience with Rust analysis:

- **Automated Scripts**:
  - `create-rust-database.sh` - Create Rust CodeQL database
  - `analyze-rust-database.sh` - Run analysis on Rust code

- **Test Project**:
  - `test-rust-project/` - Rust project with intentional code quality issues including unwrap abuse, unused variables, unreachable code, integer overflow, and empty loops

See `lab/04-rust-setup/README.md` for detailed instructions.

#### Lab 05: C++ and CMake Setup

Located in `lab/05-cpp-cmake-setup/`, this lab focuses on C++ project analysis:

- **Automated Scripts**:
  - `create-cpp-database.sh` - Create C++ CodeQL database
  - `analyze-cpp-database.sh` - Run analysis on C++ code

- **Test Project**:
  - `test-cpp-project/` - C++ project with intentional vulnerabilities including buffer overflow, null pointer dereference, memory leak, use after free, integer overflow, and command injection

## 🚀 Quick Start

### Using GitHub Codespaces (Recommended)

1. Click **Code** → **Codespaces** → **Create codespace**
2. Wait for the environment to build (~2-3 minutes)
3. Start with the lab exercises:
   ```bash
   cd lab/03-installation
   cat README.md
   ```

The Codespace includes:
- C++ compiler and CMake
- Rust toolchain
- VS Code with CodeQL extension
- All build tools pre-installed

### Local Setup

If you prefer to work locally, follow the installation guide in `03-installation.md`.

## 📋 Prerequisites

For local development:
- **C++ Development**: GCC or Clang, CMake, Ninja (or Make)
- **Rust Development**: rustc, cargo (install via rustup)
- **Editor**: VS Code with CodeQL extension
- **Git**: For cloning repositories

GitHub Codespaces provides all prerequisites pre-configured.

## 🔍 What's Included

- **Educational Content**: In-depth tutorials covering CodeQL fundamentals
- **Rust Analysis**: Complete guide and lab for Rust project analysis
- **C++ Analysis**: Complete setup and lab for C++ project analysis with CMake
- **Working Examples**: Real C++ and Rust projects with known issues
- **Automation Scripts**: Shell scripts to streamline setup and analysis

## ⚠️ Security Notice

The test projects in `lab/04-rust-setup/test-rust-project/` and
`lab/05-cpp-cmake-setup/test-cpp-project/` contain **intentionally vulnerable code**
for educational purposes. **Do not use this code in production environments.**

## 📄 License

This is an educational resource for learning CodeQL.

## 🤝 Contributing

This repository is designed as a learning resource. Feel free to explore
and adapt the materials for your own learning journey.
