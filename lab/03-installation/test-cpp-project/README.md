# 🧪 C++ Test Project for CodeQL

This is a small C++ project with **intentional security issues** and
**code quality problems** for learning CodeQL analysis.

## ⚠️ Warning

This code contains deliberately vulnerable patterns. **Do not use
in production!**

## 🎯 Intentional Issues

This project includes:

1. **Buffer Overflow** - Use of unsafe `strcpy` without bounds check
2. **Null Pointer Dereference** - Missing null check before use
3. **Memory Leak** - Allocated memory not freed
4. **Use After Free** - Access to freed memory
5. **Integer Overflow** - Unchecked arithmetic
6. **Command Injection** - Unsafe system call

## 🔨 Building

```bash
mkdir build
cd build
cmake .. -G Ninja
ninja
```

## 🔍 CodeQL Analysis

Create database:

```bash
cd lab/03-installation
./create-cpp-database.sh
```

Run analysis:

```bash
./analyze-cpp-database.sh
```

## 📊 Expected Findings

CodeQL should detect:

- CWE-120: Buffer overflow
- CWE-476: NULL pointer dereference
- CWE-401: Memory leak
- CWE-416: Use after free
- CWE-190: Integer overflow
- CWE-78: OS command injection

## 📁 Project Structure

```
test-cpp-project/
├── CMakeLists.txt        # Build configuration
├── src/
│   ├── main.cpp          # Entry point
│   ├── vulnerable.cpp    # Vulnerable functions
│   └── vulnerable.h      # Header file
└── README.md             # This file
```
