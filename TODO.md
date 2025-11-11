# 📋 CodeQL Learning Repository - TODO

## 🎯 Project Goals

Create a comprehensive learning resource for CodeQL focusing on:

- **Primary Languages**: Rust and C++ (with CMake)
- **Coding Standards**: MISRA and CERT guidelines
- **User Levels**: Beginner-friendly basics + advanced technical topics
- **Format**: Markdown files with icons, max 80 char column width
- **Method**: The reader should also need to to some lab exercised in a codespace

---

## 📦 Work Packages

### ✅ WP1: Project Planning

- [x] Create TODO.md with work breakdown

### 📚 WP2: Introduction & Fundamentals (Beginner)

- [x] `01-introduction.md`
  - What is CodeQL?
  - History and background
  - Use cases and benefits
  - When to use CodeQL

### 🏗️ WP3: Architecture & Tech Stack (Beginner → Advanced)

- [x] `02-architecture.md`
  - Tech stack overview
  - Internal architecture
  - How CodeQL works (query engine, databases)
  - Dependencies and requirements
  - Input files (source code, databases)
  - Output files (SARIF, other formats?)

### ⚙️ WP4: Installation & Configuration (Beginner)

- [x] `03-installation.md`
  - Installing CodeQL CLI
  - Setting up VS Code extension
  - System requirements
  - Basic configuration

### 🦀 WP5: Rust Setup (Beginner)

- [X] `04-rust-setup.md`
  - Rust-specific requirements
  - Creating CodeQL databases for Rust
  - Configuration for Rust projects
  - Running built-in queries
  - SARIF output handling

### 🔧 WP6: C++/CMake Setup (Beginner)

- [x] `05-cpp-cmake-setup.md`
  - C++ specific requirements
  - CMake integration
  - Creating CodeQL databases for C++
  - Configuration for CMake projects
  - Running built-in queries
  - SARIF output handling

### 🔍 WP7: Using Built-in Query Suites (Beginner)

- [x] `06-built-in-queries.md`
  - Overview of standard query packs
  - Security queries
  - Code quality queries
  - Running query suites
  - Interpreting results

### 📏 WP8: MISRA & CERT Guidelines (Beginner → Intermediate)

- [x] `07-coding-standards.md`
  - MISRA C/C++ guidelines support
  - CERT coding standards
  - Available query packs
  - Running compliance checks
  - Configuration for standards
  - Reporting and compliance
- [x] Lab 07: Coding Standards Compliance
  - MISRA C++:2008 compliance checking
  - CERT C/C++ secure coding checks
  - Compliance reporting and filtering
  - Custom compliance query suites
  - CI/CD integration examples

### 📄 WP9: SARIF Output Format (Beginner → Intermediate)

- [x] `08-sarif-output.md`
  - What is SARIF?
  - SARIF structure and format
  - Viewing and processing SARIF files
  - Other output formats supported by CodeQL
  - Integrating with CI/CD
  - Tooling ecosystem
- [x] Lab 08: SARIF Output Processing
  - SARIF file structure exploration
  - Filtering and analyzing results with jq
  - Generating reports (summary, HTML, CSV)
  - Baseline management and comparison
  - Merging multiple SARIF files
  - Metrics extraction and dashboards
  - CI/CD integration patterns

### 🔧 WP10: Advanced Configuration (Intermediate → Advanced)

- [ ] `09-advanced-config.md`
  - Database configuration options
  - Performance tuning
  - Custom database schemas
  - Query suites customization
  - Path filtering and exclusions

### 🚀 WP11: CI/CD Integration (Intermediate)

- [ ] `10-cicd-integration.md`
  - GitHub Actions integration
  - GitLab CI integration
  - Other CI systems
  - Automated scanning workflows

### ✍️ WP12: Custom Query Development (Advanced)

- [ ] `11-custom-queries.md`
  - QL language basics
  - Writing custom queries
  - Query development workflow
  - Testing queries
  - Query libraries

### 🔗 WP13: Useful Resources

- [ ] `12-useful-links.md`
  - Official documentation
  - GitHub repositories
  - Community resources
  - Tools and extensions
  - Query libraries
  - Learning resources
  - MISRA/CERT resources

### 📖 WP14: Main README

- [ ] `README.md`
  - Repository overview
  - Navigation guide
  - Quick start
  - Table of contents

### 🧪 WP15: Example Projects (Optional)

- [ ] Create example Rust project
- [ ] Create example C++/CMake project
- [ ] Include sample CodeQL configurations
- [ ] Add sample queries

---

## 📝 Content Requirements

### Formatting Standards

- ✅ Markdown format
- ✅ Icons for visual appeal
- ✅ Max 80 character column width
- ✅ Code blocks with syntax highlighting
- ✅ Clear section headers

### Content Progression

1. **Beginner Topics First**:
   - Installation
   - Basic usage
   - Running existing queries
   - Output interpretation

2. **Intermediate Topics**:
   - Configuration
   - Standards compliance
   - CI/CD integration

3. **Advanced Topics Last**:
   - Custom query development
   - Internal architecture details
   - Performance optimization

---

## 🎓 Key Topics Coverage

- ✅ CodeQL history
- ✅ Tech stack
- ✅ Dependencies
- ✅ Input files (source code, build info)
- ✅ Output files (SARIF + alternatives)
- ✅ Internal architecture
- ✅ Configuration
- ✅ Rust support
- ✅ C++/CMake support
- ✅ MISRA guidelines
- ✅ CERT guidelines
- ✅ Built-in queries (priority)
- ✅ Custom queries (advanced)

---

## 📅 Implementation Notes

- Start with beginner-friendly content
- Layer in technical depth progressively
- Include practical examples throughout
- Focus on Rust and C++ specifics
- Emphasize SARIF output format
- Include useful links compilation
