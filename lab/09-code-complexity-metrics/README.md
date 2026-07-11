# Lab 09: Code Complexity Metrics

This lab contains two parts only:

1. Measure predefined C++ metrics using the built-in CodeQL `Metrics` queries.
2. Apply thresholds to selected metrics using the custom queries in `code-complexity/`.

Both parts write CSV and SARIF.

## Prerequisites

- A C++ CodeQL database from [../05-cpp-cmake-setup](../05-cpp-cmake-setup/README.md)
- `codeql` CLI installed
- `jq` installed
- Bash shell

Examples below use:

```bash
DB_DIR=../05-cpp-cmake-setup/databases/test-cpp-db
```

## Structure

```text
lab/09-code-complexity-metrics/
├── README.md
├── measure-predefined-metrics.sh
├── apply-metric-thresholds.sh
└── code-complexity/
    ├── FileLinesOfCode.ql
    ├── FunctionComplexity.ql
    ├── FunctionLinesOfCode.ql
    ├── FunctionNumberOfParameters.ql
    ├── qlpack.yml
    └── suites/
        └── thresholds.qls
```

## Part 1: Measure Predefined Metrics

This script runs the built-in C++ metrics queries from CodeQL and writes:

- one synthesized SARIF report containing the measured rows

Run:

```bash
cd lab/09-code-complexity-metrics
./measure-predefined-metrics.sh
```

Outputs:

- `results/predefined/predefined-metrics.sarif`

Notes:

- Built-in metrics are measurement queries, not threshold violations.

## Part 2: Apply Metric Thresholds

This script runs the custom threshold queries in `code-complexity/` and writes:

- native CodeQL SARIF from the custom `@kind problem` queries
- CSV files extracted from the same query results

The script forces a fresh query evaluation (`--rerun`) when creating SARIF so changed thresholds are immediately reflected.

Run:

```bash
cd lab/09-code-complexity-metrics
./apply-metric-thresholds.sh
```

Outputs:

- `results/thresholds/threshold-metrics.sarif`
- `results/thresholds/threshold-metrics.csv`

The threshold suite currently includes:

- cyclomatic complexity per function
- lines of code per function (4) - intentionally very low to produce some results
- number of parameters per function
- lines of code per file (10) - intentionally very low to produce some results

## Quick Commands

```bash
# Measure all predefined metrics
DB_DIR=../05-cpp-cmake-setup/databases/test-cpp-db ./measure-predefined-metrics.sh

# Apply custom thresholds
DB_DIR=../05-cpp-cmake-setup/databases/test-cpp-db ./apply-metric-thresholds.sh

# Inspect one predefined metric CSV
head -20 output/predefined/csv/Functions__FunCyclomaticComplexity.csv

# Inspect threshold SARIF
jq '.runs[0].results | length' output/thresholds/sarif/threshold-metrics.sarif
```

## Related Lab

- [../05-cpp-cmake-setup](../05-cpp-cmake-setup/README.md)
