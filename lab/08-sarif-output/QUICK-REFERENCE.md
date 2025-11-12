# SARIF Processing Quick Reference

## Basic SARIF Operations

### View SARIF File
```bash
# Pretty print
jq . results.sarif | less

# View specific section
jq '.runs[0].tool' results.sarif
jq '.runs[0].results[0]' results.sarif
```

### Count and Summary
```bash
# Total findings
jq '.runs[0].results | length' results.sarif

# By severity
jq '.runs[0].results | group_by(.level) | 
    map({level: .[0].level, count: length})' results.sarif

# By rule
jq '.runs[0].results | group_by(.ruleId) | 
    map({rule: .[0].ruleId, count: length}) | 
    sort_by(-.count)' results.sarif
```

## Filtering

### By Severity
```bash
# Errors only
jq '.runs[0].results[] | select(.level == "error")' results.sarif

# Errors and warnings
jq '.runs[0].results[] | 
    select(.level == "error" or .level == "warning")' results.sarif
```

### By Rule or Tag
```bash
# Specific rule
jq '.runs[0].results[] | select(.ruleId == "cpp/unbounded-write")' results.sarif

# By tag
jq '.runs[0].results[] | 
    select(.properties.tags | contains(["security"]))' results.sarif
```

### By Precision
```bash
# High precision only
jq '.runs[0].results[] | 
    select(.properties.precision == "high")' results.sarif
```

### By File
```bash
# Specific directory
jq '.runs[0].results[] | 
    select(.locations[0].physicalLocation.artifactLocation.uri | 
           startswith("src/"))' results.sarif

# Exclude pattern
jq '.runs[0].results[] | 
    select(.locations[0].physicalLocation.artifactLocation.uri | 
           test("test") | not)' results.sarif
```

## Export to CSV

```bash
# Basic export
jq -r '.runs[0].results[] | 
    [.ruleId, .level, 
     .locations[0].physicalLocation.artifactLocation.uri,
     .locations[0].physicalLocation.region.startLine,
     .message.text] | @csv' results.sarif > findings.csv

# With headers
jq -r '
    ["Rule", "Level", "File", "Line", "Message"] as $header |
    ($header | @csv),
    (.runs[0].results[] |
        [.ruleId, .level,
         .locations[0].physicalLocation.artifactLocation.uri,
         .locations[0].physicalLocation.region.startLine,
         .message.text] | @csv
    )
' results.sarif > findings.csv
```

## Analysis Patterns

### Top Issues
```bash
# Most common rules
jq '.runs[0].results | 
    group_by(.ruleId) | 
    map({rule: .[0].ruleId, count: length}) | 
    sort_by(-.count) | 
    limit(10; .[])' results.sarif

# Most problematic files
jq '.runs[0].results | 
    group_by(.locations[0].physicalLocation.artifactLocation.uri) | 
    map({file: .[0].locations[0].physicalLocation.artifactLocation.uri, 
         issues: length}) | 
    sort_by(-.issues) | 
    limit(10; .[])' results.sarif
```

### Statistics
```bash
# Severity distribution
jq '[.runs[0].results[] | .level] | 
    group_by(.) | 
    map({severity: .[0], count: length})' results.sarif

# Precision distribution
jq '[.runs[0].results[] | .properties.precision // "unknown"] | 
    group_by(.) | 
    map({precision: .[0], count: length})' results.sarif

# Files affected
jq '[.runs[0].results[].locations[0].physicalLocation.artifactLocation.uri] | 
    unique | length' results.sarif
```

## Transformation

### Filter to New SARIF
```bash
# Keep only errors
jq '.runs[0].results |= map(select(.level == "error"))' \
    results.sarif > errors-only.sarif

# Remove specific rule
jq '.runs[0].results |= 
    map(select(.ruleId != "cpp/todo-comment"))' \
    results.sarif > filtered.sarif
```

### Add Custom Fields
```bash
# Add timestamp
jq '.runs[0].results |= map(
    .properties.scanned_at = (now | strftime("%Y-%m-%d %H:%M:%S"))
)' results.sarif > timestamped.sarif

# Add priority
jq '.runs[0].results |= map(
    .properties.priority = (
        if .level == "error" then "P1"
        elif .level == "warning" then "P2"
        else "P3"
        end
    )
)' results.sarif > prioritized.sarif
```

### Sanitize Paths
```bash
# Remove absolute paths
jq '(.runs[0].results[].locations[].physicalLocation.artifactLocation.uri |=
     sub("^/.*?/src/"; "src/"))' \
    results.sarif > sanitized.sarif

# Convert Windows paths
jq '(.runs[0].results[].locations[].physicalLocation.artifactLocation.uri |=
     gsub("\\\\"; "/"))' \
    results.sarif > normalized.sarif
```

## Comparison

### Extract Identifiers
```bash
# Create unique IDs
jq -r '.runs[0].results[] | 
    "\(.ruleId):\(.locations[0].physicalLocation.artifactLocation.uri):\(.locations[0].physicalLocation.region.startLine)"' \
    results.sarif | sort > ids.txt
```

### Compare Two Scans
```bash
# New findings
comm -13 <(extract_ids baseline.sarif) <(extract_ids current.sarif)

# Fixed findings
comm -23 <(extract_ids baseline.sarif) <(extract_ids current.sarif)

# Unchanged findings
comm -12 <(extract_ids baseline.sarif) <(extract_ids current.sarif)
```

## Suppressions

### In-Source Suppression Examples

**C/C++**:
```cpp
// Suppress specific rule
// codeql [cpp/unbounded-write] - Input size validated by caller
strcpy(buffer, input);

// Suppress on same line
strcpy(dst, src);  // lgtm [cpp/unbounded-write]

// Multiple rules
// lgtm [cpp/unbounded-write, cpp/no-space-for-terminator]
strcpy(dst, src);
```

**Rust**:
```rust
// codeql [rust/unsafe-block] - FFI requirement, safety guaranteed by C library
unsafe { ffi_call() }
```

**Python**:
```python
# lgtm [py/path-injection] - Path from trusted config only
open(filename, 'r')
```

### Query Suppressions in SARIF

```bash
# Count suppressed alerts
jq '[.runs[0].results[] | 
     select(.suppressions != null and .suppressions | length > 0)] | 
     length' results.sarif

# Show suppressed alerts
jq '.runs[0].results[] | 
    select(.suppressions != null) |
    {
      rule: .ruleId,
      file: .locations[0].physicalLocation.artifactLocation.uri,
      line: .locations[0].physicalLocation.region.startLine,
      justification: .suppressions[0].justification
    }' results.sarif

# Filter out suppressed results
jq '.runs[0].results |= 
    map(select(.suppressions == null or .suppressions | length == 0))' \
    results.sarif > unsuppressed.sarif

# Keep only suppressed results
jq '.runs[0].results |= 
    map(select(.suppressions != null and .suppressions | length > 0))' \
    results.sarif > suppressed-only.sarif
```

### Suppression Auditing

```bash
# Generate suppression CSV report
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
' results.sarif > suppressions.csv

# Count suppressions by rule
jq -r '.runs[0].results[] |
    select(.suppressions != null) |
    .ruleId' results.sarif | sort | uniq -c | sort -rn

# Find suppressions without justification
jq -r '.runs[0].results[] |
    select(.suppressions != null) |
    select(.suppressions[0].justification | 
           test("lgtm|codeql") and 
           (test("TODO|because|reason|ticket") | not)) |
    "\(.locations[0].physicalLocation.artifactLocation.uri):\(.locations[0].physicalLocation.region.startLine)"' \
    results.sarif
```

### Search Source for Suppressions

```bash
# Find all suppression comments
grep -rn "// lgtm\|// codeql" src/

# Count by rule
grep -roh "lgtm \[[^]]*\]\|codeql \[[^]]*\]" src/ | sort | uniq -c

# Find temporary suppressions
grep -rn "lgtm.*TODO\|codeql.*TODO" src/

# Find suppressions expiring soon
grep -rn "lgtm.*2025\|codeql.*2025" src/
```

## Merging

### Simple Merge
```bash
# Combine runs
jq -s '{
    version: .[0].version,
    "$schema": .[0]."$schema",
    runs: [.[].runs[]]
}' file1.sarif file2.sarif > merged.sarif
```

### Deduplicated Merge
```bash
# Combine and deduplicate results
jq -s '{
    version: .[0].version,
    "$schema": .[0]."$schema",
    runs: [{
        tool: .[0].runs[0].tool,
        results: (
            [.[].runs[].results[]] |
            unique_by(
                .ruleId + ":" +
                .locations[0].physicalLocation.artifactLocation.uri + ":" +
                (.locations[0].physicalLocation.region.startLine | tostring)
            )
        )
    }]
}' file1.sarif file2.sarif > deduped.sarif
```

## Metrics Extraction

### Dashboard Metrics
```bash
jq '{
    total: (.runs[0].results | length),
    critical: ([.runs[0].results[] | select(.level == "error")] | length),
    by_severity: (
        .runs[0].results | 
        group_by(.level) | 
        map({key: .[0].level, value: length}) | 
        from_entries
    ),
    top_rules: (
        .runs[0].results |
        group_by(.ruleId) |
        map({rule: .[0].ruleId, count: length}) |
        sort_by(-.count) |
        limit(5; .[])
    ),
    files_affected: (
        [.runs[0].results[].locations[0].physicalLocation.artifactLocation.uri] |
        unique | length
    )
}' results.sarif
```

### Time Series
```bash
# Append to CSV log
echo "$(date +%s),$(jq '.runs[0].results | length' results.sarif)" \
    >> timeseries.csv
```

## CI/CD Integration

### Quality Gate
```bash
# Check error count
ERRORS=$(jq '[.runs[0].results[] | select(.level == "error")] | length' results.sarif)
if [ "$ERRORS" -gt 0 ]; then
    echo "Build failed: $ERRORS errors found"
    exit 1
fi
```

### Compress for Artifacts
```bash
# Gzip
gzip -9 results.sarif

# Tar with metadata
tar -czf scan-results.tar.gz results.sarif metrics.json
```

### Generate Summary
```bash
# Markdown for PR comment
jq -r '"## Scan Results\n\n" +
    "**Total:** \(.runs[0].results | length)\n" +
    "**Errors:** \([.runs[0].results[] | select(.level == "error")] | length)\n" +
    "**Warnings:** \([.runs[0].results[] | select(.level == "warning")] | length)"' \
    results.sarif > summary.md
```

## Validation

```bash
# Check SARIF format
jq empty results.sarif && echo "Valid JSON" || echo "Invalid JSON"

# Validate schema (requires ajv-cli)
ajv validate -s sarif-schema-2.1.0.json -d results.sarif
```

## Streaming Large Files

```bash
# Stream processing for large SARIF
jq --stream 'select(length == 2 and .[0][1] == "ruleId") | .[1]' \
    huge-results.sarif | sort | uniq -c

# Count without loading full file
jq -n '[inputs.runs[0].results[]] | length' results.sarif
```

## Common Patterns

### Find Security Issues
```bash
jq '.runs[0].results[] | 
    select(.properties.tags | contains(["security"])) |
    {rule: .ruleId, file: .locations[0].physicalLocation.artifactLocation.uri, 
     line: .locations[0].physicalLocation.region.startLine}' \
    results.sarif
```

### Extract Code Snippets
```bash
jq -r '.runs[0].results[] | 
    "\(.locations[0].physicalLocation.artifactLocation.uri):\(.locations[0].physicalLocation.region.startLine)\n" +
    "Rule: \(.ruleId)\n" +
    "Code: \(.locations[0].physicalLocation.region.snippet.text // "N/A")\n"' \
    results.sarif
```

### Group by Directory
```bash
jq '.runs[0].results | 
    group_by(.locations[0].physicalLocation.artifactLocation.uri | 
             split("/")[0]) |
    map({directory: .[0].locations[0].physicalLocation.artifactLocation.uri | split("/")[0], 
         count: length})' \
    results.sarif
```

## File Locations

- **Scripts**: `lab/08-sarif-output/*.sh`
- **Results**: `lab/08-sarif-output/results/`
- **Baselines**: `lab/08-sarif-output/baselines/`
- **Reports**: `lab/08-sarif-output/reports/`
- **Metrics**: `lab/08-sarif-output/metrics/`

## Useful Scripts

```bash
# Generate SARIF
./generate-sarif.sh --suite security --output results/scan.sarif

# Analyze
./analyze-sarif.sh results/scan.sarif

# Filter
./filter-results.sh results/scan.sarif --level error --output results/errors.sarif

# Compare
./compare-scans.sh baselines/baseline.sarif results/new.sarif

# Report
./generate-report.sh results/scan.sarif --format html --output reports/report.html

# Metrics
./extract-metrics.sh results/scan.sarif --output metrics/current.json
```

## Troubleshooting

### jq Syntax Errors
- Check quotes and escaping
- Test expressions incrementally
- Use `jq empty file.sarif` to validate JSON

### Missing Fields
- Use `// "default"` for optional fields
- Check with `select(.field != null)`
- Verify SARIF schema version

### Performance
- Use `--stream` for large files
- Filter early in pipeline
- Limit results with `limit(N; expr)`

### Path Issues
- Normalize separators: `gsub("\\\\"; "/")`
- Remove prefixes: `sub("^.*?/src/"; "src/")`
- Use relative paths when possible
