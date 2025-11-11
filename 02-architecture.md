# 🏗️ CodeQL Architecture & Tech Stack

## 🎯 Overview

CodeQL transforms your source code into a queryable database,
allowing you to search for patterns using a declarative query
language. This document explores how CodeQL works internally and
what technologies power it.

---

## 📊 High-Level Architecture

```txt
┌─────────────────────────────────────────────────────────────┐
│                    CodeQL Workflow                          │
└─────────────────────────────────────────────────────────────┘

Source Code                CodeQL Database            Results
    │                            │                        │
    ├──> 1. Extract ──────────>  ├──> 3. Query ────────>  │
    │    (Parser/Compiler)       │    (QL Engine)         │
    │                            │                        │
    └──> 2. Build Database ────> │                        │
         (Schema Population)     │                        │
                                 │                        │
                            ┌────┴────┐                   │
                            │         │                   │
                         Entities  Relations              │
                         (Classes, (Calls, Data Flow)     │
                          Functions,                      │
                          Variables)                      │
                                                          │
                                                     SARIF Output
                                                     CSV, JSON, etc.
```

### The Three Phases

1. **Extraction**: Parse source code and extract semantic information
2. **Database Creation**: Store extracted data in a relational format
3. **Query Execution**: Run QL queries against the database

---

## 🔧 Tech Stack Components

### Core Technologies

**1. Extractor (Language-Specific)**

- Written in: C++, Java, and language-specific tools
- Purpose: Parse source code and extract syntax/semantics
- For C++: Uses Clang/LLVM infrastructure
- For Rust: Uses rust-analyzer and custom extractors
- Output: TRAP files (Tuples, Relations, Attributes, Predicates)

**2. CodeQL CLI**

- Written in: Java (primary), some native components
- Purpose: Orchestrate database creation and query execution
- Commands: `codeql database create`, `codeql query run`, etc.

**3. Query Engine**

- Written in: Java with native optimizations
- Purpose: Execute QL queries efficiently
- Features: Query optimization, incremental evaluation
- Based on: Datalog-style logic programming

**4. QL Language**

- Type: Declarative, object-oriented query language
- Paradigm: Logic programming (similar to Datalog/Prolog)
- Features: Classes, predicates, recursion, joins

**5. Database Format**

- Type: Custom relational database
- Storage: Compressed binary format
- Structure: Tables with typed columns
- Indexing: Optimized for query patterns

### Supporting Tools

**VS Code Extension**

- Purpose: IDE integration for query development
- Features: Syntax highlighting, query running, result viewing
- Written in: TypeScript

**Query Libraries**

- Standard library per language (C++, Rust, etc.)
- Community queries from GitHub Security Lab
- Organized by language and category

---

## 🗄️ Internal Architecture

### Database Schema

Each language has its own schema defining:

**Syntactic Elements**

- Abstract Syntax Tree (AST) nodes
- Tokens and lexical elements
- Source location information

**Semantic Information**

- Type information
- Symbol resolution
- Scope and binding

**Control Flow**

- Control flow graphs (CFG)
- Basic blocks
- Successor/predecessor relationships

**Data Flow**

- Data flow graphs (DFG)
- Variable definitions and uses
- Taint tracking information

### Example: C++ Schema Elements

```txt
Table: Function
Columns: id, name, signature, return_type

Table: FunctionCall
Columns: id, caller_id, callee_id, location

Table: Variable
Columns: id, name, type, scope

Table: ControlFlowNode
Columns: id, function_id, successor_id, type
```

---

## 🔄 How CodeQL Works: Deep Dive

### Phase 1: Extraction

**For C++ (using Clang):**

1. **Compilation Interception**
   - CodeQL intercepts your build commands
   - Observes how the compiler is invoked
   - Captures all source files, headers, and flags

2. **AST Generation**
   - Uses Clang to parse C++ code
   - Generates full Abstract Syntax Tree
   - Resolves all includes and templates

3. **Semantic Analysis**
   - Type checking and resolution
   - Template instantiation
   - Symbol resolution across translation units

4. **TRAP File Generation**
   - Extracts facts in TRAP format
   - Example: `function(#123, "myFunc", "void(int)")`
   - Relations: `calls(#456, #123)` (function 456 calls 123)

**For Rust:**

1. **Cargo Integration**
   - Integrates with Cargo build system
   - Uses `cargo check` or `cargo build`
   - Captures all dependencies

2. **HIR/MIR Analysis**
   - Accesses Rust's High-level IR (HIR)
   - Optionally uses Mid-level IR (MIR)
   - Extracts borrow checker information

3. **Trait Resolution**
   - Resolves trait implementations
   - Captures generic instantiations
   - Tracks lifetime information

4. **TRAP File Generation**
   - Similar to C++, but Rust-specific entities
   - Includes ownership and lifetime facts

### Phase 2: Database Creation

```txt
TRAP Files → Import → Relations → Index → CodeQL Database
```

1. **Import TRAP Files**
   - Parse all generated TRAP files
   - Validate data integrity

2. **Populate Relations**
   - Load facts into database tables
   - Resolve cross-references

3. **Build Indices**
   - Create indices for efficient querying
   - Optimize for common query patterns

4. **Compress & Package**
   - Compress database for storage
   - Create metadata files

**Database Structure:**

```txt
my-database/
├── db-cpp/           # Language-specific database
│   ├── default/      # Default dataset
│   │   ├── cache/    # Query caches
│   │   └── *.rel     # Relation files
│   └── semmlecode.cpp.dbscheme  # Schema definition
├── src.zip           # Original source code
├── codeql-database.yml  # Database metadata
└── log/              # Extraction logs
```

### Phase 3: Query Execution

1. **Query Parsing**
   - Parse QL query syntax
   - Type checking and validation

2. **Query Optimization**
   - Rewrite rules for efficiency
   - Join order optimization
   - Predicate inlining

3. **Evaluation**
   - Execute optimized query plan
   - Incremental evaluation where possible
   - Parallel execution for independent predicates

4. **Result Formatting**
   - Generate results in requested format
   - Add source locations and context
   - Format as SARIF, CSV, JSON, etc.

---

## 📦 Dependencies & Requirements

### For Database Creation

**C++ Projects:**

- Working C++ compiler (GCC, Clang, MSVC)
- Build system (CMake, Make, Ninja, etc.)
- All project dependencies
- CodeQL CLI

**Rust Projects:**

- Rust toolchain (rustc, cargo)
- Project dependencies (Cargo will fetch)
- CodeQL CLI

### For Query Execution

**Minimum:**

- CodeQL CLI
- Created CodeQL database
- Query files (.ql)

**Recommended:**

- VS Code with CodeQL extension
- Standard query libraries
- Sufficient RAM (depends on database size)

### System Requirements

**CPU:**

- Modern multi-core processor recommended
- Parallel query execution benefits from more cores

**RAM:**

- Minimum: 4GB
- Recommended: 8GB+ for large projects
- Large projects may need 16GB+

**Disk:**

- Database size: typically 10-50% of source code size
- Compressed: usually smaller
- Example: 100MB source ≈ 10-50MB database

---

## 📥 Input Files

### Source Code

- Primary input: your actual source code
- All languages: `.cpp`, `.hpp`, `.rs`, etc.
- Includes: headers, dependencies

### Build Information

- **C++**: Build commands, compiler flags, include paths
- **Rust**: `Cargo.toml`, build configuration
- Build logs (generated during extraction)

### Extraction Configuration (Optional)

- `.codeqlconfig` or similar
- Path filters (include/exclude patterns)
- Custom extractor options

### Query Files

- `.ql` files containing queries
- `.qls` files (query suites)
- `.qll` files (query libraries)

---

## 📤 Output Files

### SARIF Format (Primary) 🌟

**What is SARIF?**

- **S**tatic **A**nalysis **R**esults **I**nterchange **F**ormat
- Industry standard (OASIS standard)
- JSON-based format
- Version: Currently 2.1.0

**SARIF Structure:**

```json
{
  "version": "2.1.0",
  "$schema": "https://...",
  "runs": [{
    "tool": {
      "driver": {
        "name": "CodeQL",
        "version": "2.15.0"
      }
    },
    "results": [{
      "ruleId": "cpp/path-injection",
      "message": { "text": "..." },
      "locations": [{
        "physicalLocation": {
          "artifactLocation": { "uri": "file.cpp" },
          "region": { "startLine": 42 }
        }
      }],
      "codeFlows": [ /* data flow paths */ ]
    }]
  }]
}
```

**Benefits of SARIF:**

- ✅ Tool-agnostic (works with many security tools)
- ✅ Rich location information
- ✅ Supports data flow visualization
- ✅ Integrates with IDEs and CI/CD
- ✅ Human and machine-readable

**SARIF Viewers:**

- VS Code SARIF Viewer extension
- GitHub Security tab (native support)
- Microsoft SARIF viewer
- Various online viewers

### Other Output Formats

**1. CSV (Comma-Separated Values)**

```bash
codeql query run --output=results.csv query.ql
```

- Simple tabular format
- Easy to process with scripts
- Limited context information

**2. JSON (Custom CodeQL Format)**

```bash
codeql query run --output=results.json query.ql
```

- More detailed than CSV
- Not SARIF standard
- Includes query metadata

**3. BQRS (Binary Query Results)**

```bash
codeql query run --output=results.bqrs query.ql
```

- Native CodeQL format
- Compact binary representation
- Can be converted to other formats
- Fast to generate

**4. XML**

- Less common
- Available via conversion tools
- Used by some legacy systems

**5. Interpreted Results (Terminal)**

```bash
codeql query run query.ql
```

- Human-readable text output
- Direct to console
- Good for quick testing

### Output Comparison

|  Format  | Size     | Human-Readable | Tool Support | Use Case    |
|----------|----------|----------------|--------------|-------------|
| SARIF    | Large    | Moderate       | ⭐⭐⭐⭐⭐   | CI/CD, IDE  |
| CSV      | Small    | High           | ⭐⭐⭐       | Reports     |
| JSON     | Medium   | Moderate       | ⭐⭐⭐⭐     | Scripting   |
| BQRS     | Smallest | No             | ⭐⭐         | Internal    |
| Terminal | N/A      | High           | ⭐           | Testing     |

---

## 🔍 Query Language (QL) Overview

### Language Characteristics

**Declarative:**

- Describe *what* you want, not *how* to find it
- Similar to SQL, but more powerful

**Object-Oriented:**

- Classes and inheritance
- Methods (member predicates)
- Abstraction and reuse

**Logic Programming:**

- Based on Datalog
- Predicates, quantifiers, recursion
- Automatic join optimization

### Simple Query Example

```ql
import cpp

from FunctionCall call
where call.getTarget().getName() = "strcpy"
select call, "Use of unsafe strcpy function"
```

**Breakdown:**

- `import cpp`: Import C++ standard library
- `from`: Declare variables (like SQL)
- `where`: Filter conditions
- `select`: Output results

### Why QL is Powerful

1. **Transitive Relationships**

   ```ql
   // Find all functions that eventually call 'dangerous'
   call.getTarget().calls*().getName() = "dangerous"
   ```

2. **Data Flow Analysis**

   ```ql
   // Track user input to dangerous sink
   config.hasFlowPath(source, sink)
   ```

3. **Pattern Matching**

   ```ql
   // Find specific AST patterns
   if exists(ReturnStmt r | r.getExpr() = null)
   ```

---

## 🔧 Configuration

### Database Creation Config

**Path Filters** (`.codeqlconfig`):

```yaml
paths:
  - include: "src/**"
  - exclude: "tests/**"
  - exclude: "build/**"
```

**Build Command Override:**

```bash
codeql database create db --language=cpp \
  --command="cmake --build build"
```

### Query Execution Config

**Query Suites** (`.qls`):

```yaml
- description: Security queries for C++
- query: security/*.ql
- exclude:
    tags contain: experimental
```

**Analysis Config** (`.github/codeql/config.yml`):

```yaml
queries:
  - uses: security-extended
  - uses: security-and-quality

paths-ignore:
  - '**/*.test.cpp'
  - 'third-party/**'
```

---

## 🧩 Extensibility

### Custom Extractors

- Write your own for unsupported languages
- Extend existing extractors
- Add custom semantic information

### Custom Libraries

- Create reusable query libraries
- Share across projects
- Build domain-specific abstractions

### Tool Integration

- CodeQL CLI can be scripted
- APIs for tool integration
- SARIF output integrates with toolchains

---

## 📚 Key Takeaways

1. **CodeQL = Database + Query Engine**
   - Code is extracted into a queryable database
   - QL language queries the database

2. **Three-Phase Process**
   - Extract → Build Database → Query

3. **Language-Specific Extractors**
   - Different extractor for each language
   - C++ uses Clang, Rust uses rust-analyzer

4. **SARIF is the Standard Output**
   - Industry-standard format
   - Best for tooling integration
   - Other formats available (CSV, JSON, BQRS)

5. **Powerful Query Language**
   - Logic programming with OOP features
   - Built for code analysis patterns

---

## 📖 Next Steps

- ⚙️ **[Installation Guide](03-installation.md)** - Set up CodeQL on your system
- 🦀 **[Rust Setup](04-rust-setup.md)** - Configure for Rust projects
- 🔧 **[C++/CMake Setup](05-cpp-cmake-setup.md)** - Configure for C++ projects

---

## 🔗 References

- [CodeQL CLI Reference](https://codeql.github.com/docs/codeql-cli/)
- [QL Language Handbook](https://codeql.github.com/docs/ql-language-reference/)
- [SARIF Specification](https://sarifweb.azurewebsites.net/)
- [CodeQL Schemas](https://github.com/github/codeql)
