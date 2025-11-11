# Coding Standards Lab Quick Reference

## Running Standards Checks

### MISRA Compliance
```bash
# Run all MISRA checks
./run-misra-checks.sh

# Filter by obligation level
./filter-by-obligation.sh results/misra-results.sarif required
./filter-by-obligation.sh results/misra-results.sarif advisory
```

### CERT Compliance
```bash
# Run all CERT checks
./run-cert-checks.sh

# Manual analysis with custom suite
codeql database analyze ../05-cpp-cmake-setup/databases/test-cpp-db \
  compliance-suites/cert-security.qls \
  --format=sarif-latest \
  --output=results/cert-security.sarif
```

## Report Generation

```bash
# Generate comprehensive compliance report
./generate-report.sh results/

# View report
cat results/compliance-report.txt

# Export to CSV for analysis
# (CSV files generated automatically with reports)
ls results/*.csv
```

## Custom Query Suites

```bash
# Interactive suite creator
./create-compliance-suite.sh

# Use predefined suites
codeql database analyze <database> \
  compliance-suites/misra-required.qls \
  --format=sarif-latest --output=results.sarif
```

### Available Suites
- `misra-required.qls` - Critical MISRA rules only
- `misra-advisory.qls` - Recommended MISRA rules
- `cert-security.qls` - Security-focused CERT rules

## Result Filtering with jq

```bash
# Count violations by severity
jq '.runs[0].results | group_by(.level) | 
    map({level: .[0].level, count: length})' results.sarif

# Extract error-level findings
jq '.runs[0].results[] | select(.level == "error")' results.sarif

# Group by rule ID
jq '.runs[0].results | group_by(.ruleId) | 
    map({rule: .[0].ruleId, count: length}) | 
    sort_by(-.count)' results.sarif

# Export specific violations
jq -r '.runs[0].results[] | 
    select(.ruleId | startswith("cpp/cert/arr")) | 
    "\(.ruleId): \(.locations[0].physicalLocation.artifactLocation.uri):\(.locations[0].physicalLocation.region.startLine)"' \
    results.sarif
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run MISRA Checks
  run: |
    codeql database analyze ${{ env.DB }} \
      compliance-suites/misra-required.qls \
      --format=sarif-latest \
      --output=misra-results.sarif
    
- name: Upload Results
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: misra-results.sarif
```

### Jenkins Pipeline
```groovy
stage('CERT Compliance') {
    steps {
        sh '''
            codeql database analyze ${DB_PATH} \
              compliance-suites/cert-security.qls \
              --format=sarif-latest \
              --output=cert-results.sarif
        '''
    }
}
```

## Common Patterns

### Baseline Creation
```bash
# Create baseline (first run)
./run-misra-checks.sh
cp results/misra-results.sarif baselines/misra-baseline.sarif

# Compare against baseline (future runs)
diff <(jq '.runs[0].results | sort_by(.ruleId)' baselines/misra-baseline.sarif) \
     <(jq '.runs[0].results | sort_by(.ruleId)' results/misra-results.sarif)
```

### Fail Build on Violations
```bash
# Check for critical violations
CRITICAL=$(jq '[.runs[0].results[] | 
    select(.rule.properties.tags | 
    contains(["external/misra/obligation/required"]))] | length' \
    results/misra-results.sarif)

if [ "$CRITICAL" -gt 0 ]; then
    echo "Build failed: $CRITICAL critical violations found"
    exit 1
fi
```

### Track Compliance Over Time
```bash
# Log violation counts
echo "$(date),MISRA,$(jq '.runs[0].results | length' results/misra-results.sarif)" \
    >> compliance-history.csv
echo "$(date),CERT,$(jq '.runs[0].results | length' results/cert-results.sarif)" \
    >> compliance-history.csv
```

## File Locations

- **Scripts**: `lab/07-coding-standards/*.sh`
- **Results**: `lab/07-coding-standards/results/`
- **Query Suites**: `lab/07-coding-standards/compliance-suites/`
- **Reports**: `lab/07-coding-standards/results/compliance-report.txt`
- **CSV Exports**: `lab/07-coding-standards/results/*-violations.csv`

## Useful Commands

```bash
# List all available MISRA queries
codeql resolve queries codeql/cpp-queries --format=bylanguage | \
  grep -i misra

# List all available CERT queries  
codeql resolve queries codeql/cpp-queries --format=bylanguage | \
  grep -i cert

# View query metadata
codeql resolve metadata codeql/cpp-queries/<query-path>

# Validate query suite
codeql resolve qlpacks compliance-suites/misra-required.qls
```

## Troubleshooting

### No violations found
- Verify database exists: `ls -la ../05-cpp-cmake-setup/databases/test-cpp-db`
- Check query packs: `codeql resolve qlpacks | grep cpp`
- Verify tags: `codeql resolve queries codeql/cpp-queries --format=bylanguage`

### jq errors
```bash
# Install jq if missing
sudo apt-get update && sudo apt-get install -y jq

# Validate SARIF format
jq empty results.sarif
```

### Performance issues
```bash
# Limit analysis scope
codeql database analyze <db> <suite> \
  --max-paths=4 \
  --threads=0 \
  --ram=4096
```
