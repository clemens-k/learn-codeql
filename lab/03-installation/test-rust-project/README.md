# 🦀 Rust Test Project for CodeQL

This is a small Rust project with **intentional code quality issues**
for learning CodeQL analysis.

## ⚠️ Note

This code contains deliberately problematic patterns for educational
purposes. While Rust's safety features prevent many of the memory
issues possible in C++, CodeQL can still find logic bugs and code
quality problems.

## 🎯 Intentional Issues

This project includes:

1. **Unused Variables** - Declared but never used
2. **Unreachable Code** - Code after unconditional return
3. **Unwrap Abuse** - Potential panics from `unwrap()`
4. **Integer Overflow** - Unchecked arithmetic in debug mode
5. **Empty Loop** - Inefficient or incorrect logic
6. **Clone on Copy** - Unnecessary performance overhead

## 🔨 Building

```bash
cargo build
cargo run
```

## 🔍 CodeQL Analysis

Create database:

```bash
cd lab/03-installation
./create-rust-database.sh
```

Run analysis:

```bash
./analyze-rust-database.sh
```

## 📊 Expected Findings

CodeQL should detect:

- Unused variables
- Unreachable code
- Potential panics (unwrap on Result/Option)
- Integer overflow risks
- Code quality issues
- Suboptimal patterns

## 📁 Project Structure

```
test-rust-project/
├── Cargo.toml         # Package manifest
├── src/
│   ├── main.rs        # Entry point with examples
│   └── lib.rs         # Library with problematic code
└── README.md          # This file
```
