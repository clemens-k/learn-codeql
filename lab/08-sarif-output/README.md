# Lab 08: SARIF Output Processing

## Overview

This lab teaches you how to work with SARIF (Static Analysis Results 
Interchange Format) files produced by CodeQL. You'll learn to process, 
analyze, filter, and visualize SARIF data using command-line tools and 
scripts.

**Duration**: 60-90 minutes  
**Difficulty**: Beginner to Intermediate

## Learning Objectives

By completing this lab, you will:

- ✅ Understand SARIF file structure and components
- ✅ Process SARIF files using jq for filtering and analysis
- ✅ Generate custom reports from SARIF data
- ✅ Merge and compare SARIF files from multiple scans
- ✅ Create baselines and track new findings
- ✅ Work with in-source alert suppressions
- ✅ Integrate SARIF output with CI/CD pipelines
- ✅ Build dashboards and metrics from scan results

## Prerequisites

- Completed Lab 05 (C++ database available) or Lab 04 (Rust database)
- CodeQL CLI installed and configured
- `jq` installed for JSON processing
- Basic understanding of JSON and shell scripting

**Verify Prerequisites**:
```bash
# Check CodeQL
codeql --version

# Check jq
jq --version

# Check for existing database
ls -la ../05-cpp-cmake-setup/databases/test-cpp-db/ || \
ls -la ../04-rust-setup/databases/test-rust-db/
```

## Lab Structure

```
lab/08-sarif-output/
├── README.md                    # This file
├── quick-start.sh               # Interactive menu
├── suppression-examples.cpp     # Example file with various suppression patterns
├── generate-sarif.sh            # Generate sample SARIF files
├── analyze-sarif.sh             # Basic SARIF analysis
├── compare-scans.sh             # Compare two SARIF files
├── create-baseline.sh           # Create and manage baselines
├── filter-results.sh            # Filter by various criteria
├── merge-sarif.sh               # Merge multiple SARIF files
├── generate-report.sh           # Create HTML/CSV reports
├── extract-metrics.sh           # Extract metrics and statistics
├── validate-sarif.sh            # Validate SARIF format
├── QUICK-REFERENCE.md           # Command reference
├── results/                     # Generated SARIF files
├── baselines/                   # Baseline files
├── reports/                     # Generated reports
└── metrics/                     # Extracted metrics
```

## Exercise 1: Understanding SARIF Structure

**Objective**: Explore SARIF file structure and key components.

### Step 1: Generate Sample SARIF

```bash
./generate-sarif.sh
```

This script creates several SARIF files from your existing database using 
different query suites.

### Step 2: Examine SARIF Structure

```bash
# View formatted SARIF
jq . results/security-scan.sarif | less

# Count total findings
jq '.runs[0].results | length' results/security-scan.sarif

# List top-level keys
jq 'keys' results/security-scan.sarif
```

### Step 3: Explore Tool Information

```bash
# View tool metadata
jq '.runs[0].tool.driver' results/security-scan.sarif

# List all rules
jq '.runs[0].tool.driver.rules[] | {id, name}' \
  results/security-scan.sarif

# Count rules by tag
jq '[.runs[0].tool.driver.rules[].properties.tags[]?] | 
    group_by(.) | 
    map({tag: .[0], count: length}) | 
    sort_by(-.count)' \
  results/security-scan.sarif
```

### Step 4: Analyze Results

```bash
# View first result in detail
jq '.runs[0].results[0]' results/security-scan.sarif

# List all rule IDs
jq -r '.runs[0].results[].ruleId' results/security-scan.sarif | \
  sort | uniq

# Group by severity
jq '.runs[0].results | 
    group_by(.level) | 
    map({level: .[0].level, count: length})' \
  results/security-scan.sarif
```

**Expected Output**:
- Understanding of SARIF schema version and structure
- Tool metadata (CodeQL version, rules used)
- Results array with findings
- Location information for each finding

## Exercise 2: Filtering and Analyzing Results

**Objective**: Filter SARIF files by various criteria.

### Step 1: Filter by Severity

```bash
# Extract only errors
jq '.runs[0].results |= 
    map(select(.level == "error"))' \
  results/security-scan.sarif > results/errors-only.sarif

# Count by severity level
jq '.runs[0].results | 
    group_by(.level) | 
    map({level: .[0].level, count: length})' \
  results/security-scan.sarif
```

### Step 2: Filter by Rule or Tag

```bash
# Using the filter script
./filter-results.sh results/security-scan.sarif \
  --rule "cpp/unbounded-write" \
  --output results/filtered.sarif

# Filter by tag
./filter-results.sh results/security-scan.sarif \
  --tag "security" \
  --output results/security-only.sarif

# Filter by precision
./filter-results.sh results/security-scan.sarif \
  --precision "high" \
  --output results/high-precision.sarif
```

### Step 3: Filter by File or Directory

```bash
# Only results from src/ directory
jq '.runs[0].results |= 
    map(select(.locations[0].physicalLocation.artifactLocation.uri | 
               startswith("src/")))' \
  results/security-scan.sarif > results/src-only.sarif

# Exclude test files
jq '.runs[0].results |= 
    map(select(.locations[0].physicalLocation.artifactLocation.uri | 
               test("test") | not))' \
  results/security-scan.sarif > results/no-tests.sarif
```

**Expected Output**:
- Filtered SARIF files with specific subsets of results
- Understanding of filter criteria (severity, rules, tags, files)
- Reduced result sets for focused analysis

## Exercise 3: Generating Reports

**Objective**: Create human-readable reports from SARIF data.

### Step 1: Generate Summary Report

```bash
./generate-report.sh results/security-scan.sarif \
  --format summary \
  --output reports/summary.txt

cat reports/summary.txt
```

### Step 2: Generate Detailed HTML Report

```bash
./generate-report.sh results/security-scan.sarif \
  --format html \
  --output reports/detailed.html

# View in browser (if available)
xdg-open reports/detailed.html 2>/dev/null || \
  open reports/detailed.html 2>/dev/null || \
  echo "Open reports/detailed.html in your browser"
```

### Step 3: Export to CSV

```bash
./generate-report.sh results/security-scan.sarif \
  --format csv \
  --output reports/findings.csv

# View CSV
column -t -s ',' reports/findings.csv | head -20
```

### Step 4: Create Custom Report

```bash
# Top 10 most common issues
jq -r '
  .runs[0].results | 
  group_by(.ruleId) | 
  map({rule: .[0].ruleId, count: length, message: .[0].message.text}) |
  sort_by(-.count) | 
  limit(10; .[]) |
  "\(.count)x \(.rule): \(.message)"
' results/security-scan.sarif

# Files with most issues
jq -r '
  .runs[0].results | 
  group_by(.locations[0].physicalLocation.artifactLocation.uri) | 
  map({file: .[0].locations[0].physicalLocation.artifactLocation.uri, 
       issues: length}) |
  sort_by(-.issues) |
  limit(10; .[]) |
  "\(.issues) issues in \(.file)"
' results/security-scan.sarif
```

**Expected Output**:
- Text summary with finding counts
- HTML report with interactive navigation
- CSV file for spreadsheet analysis
- Custom analyses showing patterns and hotspots

## Exercise 4: Baseline Management

**Objective**: Create baselines and track new findings over time.

### Step 1: Create Initial Baseline

```bash
./create-baseline.sh results/security-scan.sarif

# Verify baseline created
ls -lh baselines/
```

### Step 2: Simulate Code Changes

```bash
# Generate a new scan (simulating a new commit)
./generate-sarif.sh --output results/new-scan.sarif
```

### Step 3: Compare Against Baseline

```bash
./compare-scans.sh \
  baselines/baseline-$(date +%Y%m%d).sarif \
  results/new-scan.sarif \
  --output reports/diff-report.txt

cat reports/diff-report.txt
```

### Step 4: Identify New Issues

```bash
# Extract new findings
./compare-scans.sh \
  baselines/baseline-*.sarif \
  results/new-scan.sarif \
  --format new-only \
  --output results/new-issues.sarif

# Count new issues
jq '.runs[0].results | length' results/new-issues.sarif
```

**Expected Output**:
- Baseline file in `baselines/` directory
- Comparison report showing new, fixed, and unchanged issues
- SARIF file containing only new findings
- Understanding of how to track security debt over time

## Exercise 5: Merging Multiple Scans

**Objective**: Combine SARIF files from different tools or scans.

### Step 1: Generate Multiple SARIF Files

```bash
# Generate from different query suites
./generate-sarif.sh --suite security --output results/security.sarif
./generate-sarif.sh --suite quality --output results/quality.sarif
./generate-sarif.sh --suite extended --output results/extended.sarif
```

### Step 2: Merge SARIF Files

```bash
./merge-sarif.sh \
  results/security.sarif \
  results/quality.sarif \
  --output results/combined.sarif

# Verify merge
jq '.runs | length' results/combined.sarif
jq '.runs[].tool.driver.name' results/combined.sarif
```

### Step 3: Deduplicate Results

```bash
./merge-sarif.sh \
  results/security.sarif \
  results/extended.sarif \
  --deduplicate \
  --output results/deduped.sarif

# Compare counts
echo "Security: $(jq '.runs[0].results | length' results/security.sarif)"
echo "Extended: $(jq '.runs[0].results | length' results/extended.sarif)"
echo "Combined: $(jq '.runs[0].results | length' results/combined.sarif)"
echo "Deduped:  $(jq '.runs[0].results | length' results/deduped.sarif)"
```

**Expected Output**:
- Combined SARIF file with multiple runs
- Understanding of SARIF merge strategies
- Deduplicated results removing overlaps
- Metrics showing before/after merge counts

## Exercise 6: Metrics and Dashboards

**Objective**: Extract metrics for tracking and visualization.

### Step 1: Extract Basic Metrics

```bash
./extract-metrics.sh results/security-scan.sarif \
  --output metrics/current.json

cat metrics/current.json
```

### Step 2: Build Time Series Data

```bash
# Simulate multiple scans over time
for i in {1..5}; do
  ./generate-sarif.sh --output results/scan-$i.sarif
  ./extract-metrics.sh results/scan-$i.sarif \
    --output metrics/scan-$i.json
  sleep 1
done

# Combine into time series
jq -s '.' metrics/scan-*.json > metrics/timeseries.json
```

### Step 3: Generate Dashboard Data

```bash
# Create dashboard metrics
jq '{
  total_findings: (.runs[0].results | length),
  severity_breakdown: (
    .runs[0].results | 
    group_by(.level) | 
    map({level: .[0].level, count: length})
  ),
  top_5_rules: (
    .runs[0].results |
    group_by(.ruleId) |
    map({rule: .[0].ruleId, count: length}) |
    sort_by(-.count) |
    limit(5; .[])
  ),
  files_affected: (
    [.runs[0].results[].locations[0].physicalLocation.artifactLocation.uri] |
    unique | length
  ),
  high_severity_files: (
    .runs[0].results |
    map(select(.level == "error")) |
    group_by(.locations[0].physicalLocation.artifactLocation.uri) |
    map({file: .[0].locations[0].physicalLocation.artifactLocation.uri, 
         count: length}) |
    sort_by(-.count) |
    limit(5; .[])
  )
}' results/security-scan.sarif > metrics/dashboard.json

cat metrics/dashboard.json
```

### Step 4: Track Trends

```bash
# Extract finding counts over time
jq -r '[.timestamp, .total_findings] | @csv' \
  metrics/timeseries.json > metrics/trend.csv

# View trend
cat metrics/trend.csv
```

**Expected Output**:
- JSON files with structured metrics
- Time series data showing scan evolution
- Dashboard-ready JSON with key indicators
- Trend data for visualization

## Exercise 7: CI/CD Integration

**Objective**: Prepare SARIF for CI/CD pipeline integration.

### Step 1: Validate SARIF Format

```bash
./validate-sarif.sh results/security-scan.sarif

# Check exit code
echo "Validation status: $?"
```

### Step 2: Quality Gate Check

```bash
# Create quality gate script
cat > check-quality-gate.sh << 'EOF'
#!/bin/bash
set -e

SARIF_FILE=$1
MAX_ERRORS=${2:-0}

ERRORS=$(jq '[.runs[0].results[] | 
              select(.level == "error")] | length' "$SARIF_FILE")

echo "Found $ERRORS error-level findings (max: $MAX_ERRORS)"

if [ "$ERRORS" -gt "$MAX_ERRORS" ]; then
    echo "❌ Quality gate FAILED"
    exit 1
else
    echo "✅ Quality gate PASSED"
    exit 0
fi
EOF

chmod +x check-quality-gate.sh

# Test quality gate
./check-quality-gate.sh results/security-scan.sarif 5
```

### Step 3: Prepare for Upload

```bash
# Sanitize paths for sharing
jq '(.runs[0].results[].locations[].physicalLocation.artifactLocation.uri |=
     sub("^.*/"; ""))' \
  results/security-scan.sarif > results/sanitized.sarif

# Compress for artifact storage
gzip -9 -c results/sanitized.sarif > results/scan-results.sarif.gz

ls -lh results/scan-results.sarif.gz
```

### Step 4: Generate CI Summary

```bash
# Create pipeline summary
jq -r '
  "## CodeQL Scan Results\n\n" +
  "**Total Findings**: \(.runs[0].results | length)\n\n" +
  "### By Severity\n" +
  (.runs[0].results | group_by(.level) | 
   map("- **\(.[0].level)**: \(length)") | join("\n")) +
  "\n\n### Top Issues\n" +
  (.runs[0].results | group_by(.ruleId) | 
   map({rule: .[0].ruleId, count: length}) | sort_by(-.count) |
   limit(5; .[]) | 
   map("- \(.rule): \(.count)x") | join("\n"))
' results/security-scan.sarif > reports/ci-summary.md

cat reports/ci-summary.md
```

**Expected Output**:
- Valid SARIF files passing format checks
- Quality gate script with configurable thresholds
- Sanitized and compressed SARIF for CI artifacts
- Markdown summary for pipeline output

## Exercise 8: Advanced SARIF Processing

**Objective**: Perform complex SARIF transformations and analyses.

### Step 1: Extract Code Flows

```bash
# Find results with code flows
jq '.runs[0].results[] | 
    select(.codeFlows != null) |
    {
      rule: .ruleId,
      message: .message.text,
      flow_steps: .codeFlows[0].threadFlows[0].locations | length
    }' results/security-scan.sarif
```

### Step 2: Analyze Related Locations

```bash
# Extract results with related locations
jq '.runs[0].results[] |
    select(.relatedLocations != null) |
    {
      rule: .ruleId,
      primary: .locations[0].physicalLocation.artifactLocation.uri,
      related_count: (.relatedLocations | length)
    }' results/security-scan.sarif
```

### Step 3: Build Dependency Graph

```bash
# Extract file-to-file dependencies from code flows
jq -r '
  .runs[0].results[] |
  select(.codeFlows != null) |
  .codeFlows[0].threadFlows[0].locations[] |
  .location.physicalLocation.artifactLocation.uri
' results/security-scan.sarif | sort | uniq > reports/affected-files.txt

cat reports/affected-files.txt
```

### Step 4: Custom Enrichment

```bash
# Add custom metadata
jq '.runs[0].results |= map(
  .properties.customSeverity = (
    if .level == "error" then "CRITICAL"
    elif .level == "warning" then "MEDIUM"
    else "LOW"
    end
  ) |
  .properties.analyzed_at = (now | strftime("%Y-%m-%d %H:%M:%S"))
)' results/security-scan.sarif > results/enriched.sarif

# Verify enrichment
jq '.runs[0].results[0].properties' results/enriched.sarif
```

**Expected Output**:
- Understanding of code flows and their structure
- Analysis of related locations showing context
- List of files involved in vulnerabilities
- Enriched SARIF with custom properties

## Exercise 9: Working with Suppressions

**Objective**: Understand and manage alert suppressions in SARIF.

### Step 1: Identify Suppressions in SARIF

```bash
# Check if SARIF contains suppressions
jq '.runs[0].results[] | 
    select(.suppressions != null) | 
    {
      rule: .ruleId,
      file: .locations[0].physicalLocation.artifactLocation.uri,
      line: .locations[0].physicalLocation.region.startLine,
      justification: .suppressions[0].justification
    }' results/security-scan.sarif
```

### Step 2: Add In-Source Suppressions

Let's add suppressions to the test C++ project:

```bash
# Navigate to test project
cd ../05-cpp-cmake-setup/test-cpp-project/src/

# Add suppression comment (example)
cat main.cpp
```

Edit `main.cpp` to add a suppression:
```cpp
// Before:
strcpy(buffer, input);

// After (with suppression):
// codeql [cpp/unbounded-write] - Legacy code, refactor planned for Q1 2026
strcpy(buffer, input);
```

### Step 3: Regenerate SARIF with Suppressions

```bash
# Return to lab directory
cd ../../../08-sarif-output/

# Regenerate database and SARIF
../05-cpp-cmake-setup/create-cpp-database.sh
./generate-sarif.sh --output results/with-suppressions.sarif

# Compare before and after
echo "Before suppressions:"
jq '.runs[0].results | length' results/security-scan.sarif
echo "After suppressions:"
jq '.runs[0].results | length' results/with-suppressions.sarif
```

### Step 4: Analyze Suppressions

```bash
# Count suppressed vs unsuppressed
TOTAL=$(jq '.runs[0].results | length' results/with-suppressions.sarif)
SUPPRESSED=$(jq '[.runs[0].results[] | 
                   select(.suppressions != null and .suppressions | length > 0)] | 
                   length' results/with-suppressions.sarif)
ACTIVE=$((TOTAL - SUPPRESSED))

echo "Total results: $TOTAL"
echo "Suppressed: $SUPPRESSED"
echo "Active: $ACTIVE"
```

### Step 5: Generate Suppression Report

```bash
# Create CSV report of all suppressions
jq -r '
  ["File", "Line", "Rule", "Justification"] as $header |
  ($header | @csv),
  (.runs[0].results[] |
   select(.suppressions != null and .suppressions | length > 0) |
   [
     .locations[0].physicalLocation.artifactLocation.uri,
     .locations[0].physicalLocation.region.startLine,
     .ruleId,
     .suppressions[0].justification
   ] | @csv
  )
' results/with-suppressions.sarif > reports/suppressions.csv

cat reports/suppressions.csv
```

### Step 6: Filter Suppressed Results

```bash
# Create SARIF with only unsuppressed results
jq '.runs[0].results |= 
    map(select(.suppressions == null or .suppressions | length == 0))' \
    results/with-suppressions.sarif > results/active-only.sarif

# Create SARIF with only suppressed results
jq '.runs[0].results |= 
    map(select(.suppressions != null and .suppressions | length > 0))' \
    results/with-suppressions.sarif > results/suppressed-only.sarif

# Verify counts
echo "Active only: $(jq '.runs[0].results | length' results/active-only.sarif)"
echo "Suppressed only: $(jq '.runs[0].results | length' results/suppressed-only.sarif)"
```

### Step 7: Audit Suppressions

```bash
# Find suppressions by rule
jq -r '.runs[0].results[] |
    select(.suppressions != null) |
    .ruleId' results/with-suppressions.sarif | sort | uniq -c | sort -rn

# Find suppressions without good justification
jq -r '.runs[0].results[] |
    select(.suppressions != null) |
    select(.suppressions[0].justification | 
           test("lgtm|codeql") and 
           (test("TODO|ticket|planned|legacy|issue") | not)) |
    "\(.locations[0].physicalLocation.artifactLocation.uri):\(.locations[0].physicalLocation.region.startLine) - No justification"' \
    results/with-suppressions.sarif
```

### Step 8: Search Source Code for Suppressions

```bash
# Find all suppression comments in source
cd ../05-cpp-cmake-setup/test-cpp-project/
grep -rn "// lgtm\|// codeql" src/

# Count by rule
grep -roh "lgtm \[[^]]*\]\|codeql \[[^]]*\]" src/ | sort | uniq -c

# Find temporary suppressions (with TODO)
grep -rn "lgtm.*TODO\|codeql.*TODO" src/
```

**Expected Output**:
- Understanding of SARIF suppression structure
- Ability to add in-source suppressions
- Reports showing suppressed vs active alerts
- Audit trails for security team review
- Filtered SARIF files for different use cases

## Troubleshooting

### Issue: "jq: error parsing"

**Solution**: Validate your SARIF file
```bash
jq empty results/security-scan.sarif
```

### Issue: Empty results array

**Cause**: Query suite may not match your code or database might be incomplete

**Solution**:
```bash
# Check database contents
codeql database info ../05-cpp-cmake-setup/databases/test-cpp-db/

# Try different query suite
./generate-sarif.sh --suite security-extended
```

### Issue: Large SARIF files

**Solution**: Use streaming or filtering
```bash
# Stream large files
jq --stream 'select(length == 2 and .[0][1] == "ruleId") | .[1]' \
  large-results.sarif

# Filter before processing
jq '.runs[0].results |= map(select(.level == "error"))' \
  large-results.sarif | jq . | less
```

### Issue: Path handling in Windows/Linux

**Solution**: Normalize paths
```bash
# Convert Windows paths
jq '(.runs[0].results[].locations[].physicalLocation.artifactLocation.uri |=
     gsub("\\\\"; "/"))' results.sarif > normalized.sarif
```

## Challenge Exercises

Ready for more? Try these challenges:

### Challenge 1: Security Dashboard
Create a complete security dashboard showing:
- Total findings by severity
- Trend over last 10 scans
- Top 5 most vulnerable files
- MTTR (Mean Time To Remediation) for issues

### Challenge 2: Automated Triage
Build a script that:
- Categorizes findings by exploitability
- Assigns priority scores
- Creates GitHub issues for critical findings
- Sends Slack notifications for new issues

### Challenge 3: Compliance Reporter
Generate a compliance report showing:
- MISRA/CERT rule coverage
- Pass/fail status for each rule
- Historical compliance trends
- Executive summary

### Challenge 4: Multi-Language Analysis
Combine SARIF from:
- C++ CodeQL scan
- Rust CodeQL scan
- Third-party SAST tool
Create unified report with deduplication

## Summary

In this lab, you learned:

✅ **SARIF Structure**: Understanding runs, results, locations, and metadata  
✅ **Processing**: Using jq to filter, transform, and analyze SARIF  
✅ **Reporting**: Generating human-readable reports in multiple formats  
✅ **Baselining**: Tracking changes and new findings over time  
✅ **Merging**: Combining results from multiple scans  
✅ **Metrics**: Extracting data for dashboards and trends  
✅ **CI/CD**: Integrating SARIF processing in pipelines  
✅ **Advanced**: Code flows, enrichment, and custom analyses

## Next Steps

1. **Integrate with CI/CD**: Add SARIF processing to your build pipeline
2. **Build Dashboard**: Create visualization of your security metrics
3. **Automate Triage**: Set up automated issue creation and notifications
4. **Learn Custom Queries**: Move to Tutorial 11 for writing custom queries

## Additional Resources

- **SARIF Specification**: https://docs.oasis-open.org/sarif/sarif/v2.1.0/
- **SARIF Tutorials**: https://github.com/microsoft/sarif-tutorials
- **jq Manual**: https://stedolan.github.io/jq/manual/
- **GitHub Code Scanning API**: https://docs.github.com/rest/code-scanning

---

**Questions?** Refer to `QUICK-REFERENCE.md` for common commands and patterns.
