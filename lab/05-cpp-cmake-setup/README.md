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
