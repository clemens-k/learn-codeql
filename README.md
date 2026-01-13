# 📚 Learn CodeQL

A hands-on learning resource for understanding and using CodeQL, GitHub's
semantic code analysis engine. This repository provides comprehensive
tutorials and practical labs for analyzing code with CodeQL.

## 🎯 What You'll Learn

- **Introduction to CodeQL**: Understanding what CodeQL is and how it treats code as data
- **Architecture & Tech Stack**: How CodeQL works internally, from extraction to query execution
- **Installation & Configuration**: Setting up CodeQL CLI and VS Code extension
- **Practical Analysis**: Creating databases and running queries on real projects

**WARNING:** CodeQL is free for research and open source (OSI-compliant license).
You SHALL NOT use codeql on closed sources of non-OSI-compliant licenses without
proper license from GitHub!

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

5. **[05-cpp-cmake-setup.md](05-cpp-cmake-setup.md)** - C++ and CMake Setup for CodeQL
  - C++-specific requirements and compiler support
  - CMake integration and build system configuration
  - Creating CodeQL databases for C++ projects
  - Running built-in security queries

6. **[06-built-in-queries.md](06-built-in-queries.md)** - Using Built-in Query Suites
  - Understanding query packs and query suites
  - Available suites for C++ and Rust (code-scanning, security-and-quality, security-extended)
  - Running and customizing query execution
  - Interpreting results by severity and precision

7. **[07-coding-standards.md](07-coding-standards.md)** - MISRA & CERT Coding Standards
  - MISRA C/C++ guidelines support
  - CERT C/C++ secure coding standards
  - Running compliance checks with CodeQL
  - Interpreting compliance results

8. **[08-sarif-output.md](08-sarif-output.md)** - SARIF Output Format
  - Understanding the SARIF format
  - Processing and filtering SARIF files
  - Generating reports and metrics
  - CI/CD integration patterns

9. **[99-resources.md](99-resources.md)** - Useful Resources
  - Official CodeQL documentation and repositories
  - Learning resources and tutorials
  - MISRA and CERT standards documentation
  - Community resources and tools
  - Query libraries and packs

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

#### Lab 06: Using Built-in Query Suites

Located in `lab/06-built-in-queries/`, this lab teaches effective use of query suites:

- **Automated Scripts**:
  - `run-all-suites.sh` - Run all query suites (code-scanning, security-and-quality, security-extended)
  - `compare-suites.sh` - Compare results across different suites
  - `analyze-by-severity.sh` - Analyze findings by severity and precision
  - `filter-results.sh` - Filter SARIF results by various criteria
  - `create-custom-suite.sh` - Generate custom query suite configurations

- **Learning Focus**:
  - Understanding when to use each query suite
  - Interpreting severity levels and precision ratings
  - Creating custom query suites for specific needs
  - Comparing and filtering analysis results

See `lab/06-built-in-queries/README.md` for detailed instructions.

#### Lab 07: Coding Standards Compliance

Located in `lab/07-coding-standards/`, this lab covers MISRA and CERT compliance checking:

- **Compliance Scripts**:
  - `run-misra-checks.sh` - Run MISRA C++:2023 compliance checks
  - `run-cert-checks.sh` - Run CERT C/C++ secure coding checks
  - `generate-report.sh` - Generate comprehensive compliance reports
  - `filter-by-obligation.sh` - Filter MISRA results by obligation level
  - `create-compliance-suite.sh` - Create custom compliance query suites
  - `quick-start.sh` - Interactive menu for quick lab access

- **Custom Query Suites**:
  - `compliance-suites/misra-required.qls` - Critical MISRA rules only
  - `compliance-suites/misra-advisory.qls` - Recommended MISRA rules
  - `compliance-suites/cert-security.qls` - Security-focused CERT rules

- **Learning Focus**:
  - Understanding MISRA C++:2023 and CERT C/C++ standards
  - Running automated compliance checks with github/codeql-coding-standards
  - Filtering results by obligation level and category
  - Generating compliance reports for audits
  - Integrating standards checking in CI/CD pipelines

See `lab/07-coding-standards/README.md` for detailed instructions.

#### Lab 08: SARIF Output Processing

Located in `lab/08-sarif-output/`, this lab teaches SARIF file processing and analysis:

- **Processing Scripts**:
  - `generate-sarif.sh` - Generate SARIF files from CodeQL analysis
  - `analyze-sarif.sh` - Basic SARIF file analysis and statistics
  - `filter-results.sh` - Filter by severity, rule, tag, precision, or file
  - `compare-scans.sh` - Compare two SARIF files to track changes
  - `create-baseline.sh` - Create and manage baseline SARIF files
  - `merge-sarif.sh` - Merge multiple SARIF files with deduplication
  - `generate-report.sh` - Create reports in summary, HTML, or CSV format
  - `extract-metrics.sh` - Extract metrics for dashboards and tracking
  - `quick-start.sh` - Interactive menu for quick lab access

- **Learning Focus**:
  - Understanding SARIF structure (runs, results, locations, metadata)
  - Processing SARIF with jq for filtering and transformation
  - Generating human-readable reports in multiple formats
  - Creating baselines and tracking new findings over time
  - Merging results from multiple scans
  - Extracting metrics for dashboards and trend analysis
  - Integrating SARIF processing in CI/CD pipelines
  - Building quality gates and automated triage

See `lab/08-sarif-output/README.md` for detailed instructions.

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

MIT

## 🤝 Contributing

This repository is designed as a learning resource. Feel free to explore
and adapt the materials for your own learning journey.
