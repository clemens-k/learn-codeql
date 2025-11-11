# 📄 Understanding SARIF Output Format

## Overview

SARIF (Static Analysis Results Interchange Format) is an OASIS standard 
(ISO/IEC 30134:2021) for representing the output of static analysis tools. 
CodeQL uses SARIF as its primary output format, enabling seamless integration 
with various security and development tools.

This guide covers SARIF structure, processing techniques, and integration 
patterns for effective use of CodeQL analysis results.

## What is SARIF?

### Purpose and Design

SARIF provides:

- **Standardized Format**: Common structure across all static analysis tools
- **Rich Metadata**: Detailed information about findings and their context
- **Tool Interoperability**: Easy integration with IDEs, CI/CD, and dashboards
- **Human and Machine Readable**: JSON format with comprehensive documentation
- **Version Control Friendly**: Text-based format suitable for diff operations

### SARIF Benefits

**For Development Teams**:
- Consistent format across multiple analysis tools
- Native support in GitHub, Azure DevOps, and Visual Studio
- Easy automation and scripting with JSON processing tools
- Historical tracking and trend analysis

**For Security Teams**:
- Comprehensive vulnerability information with CWE/CVE mappings
- Severity and confidence ratings for prioritization
- Code flow and data flow visualization
- Integration with vulnerability management systems

## SARIF Structure

### Basic Document Layout

A SARIF file contains:

```json
{
  "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": { ... },
      "results": [ ... ],
      "artifacts": [ ... ],
      "invocations": [ ... ]
    }
  ]
}
```

**Key Sections**:
- `version`: SARIF format version (typically "2.1.0")
- `runs`: Array of analysis runs (one per tool execution)
- `tool`: Information about the analysis tool
- `results`: Array of findings (vulnerabilities, bugs, issues)
- `artifacts`: Files analyzed during the scan
- `invocations`: Execution details and diagnostics

### Tool Information

The `tool` section identifies the analyzer:

```json
"tool": {
  "driver": {
    "name": "CodeQL",
    "version": "2.15.3",
    "organization": "GitHub",
    "informationUri": "https://codeql.github.com/",
    "rules": [
      {
        "id": "cpp/unbounded-write",
        "name": "UnboundedWrite",
        "shortDescription": {
          "text": "Unbounded write"
        },
        "fullDescription": {
          "text": "Writing to a buffer without checking bounds..."
        },
        "properties": {
          "tags": ["security", "external/cwe/cwe-120"],
          "precision": "high",
          "problem.severity": "error"
        }
      }
    ]
  }
}
```

**Tool Properties**:
- `name`: Tool identifier
- `version`: Tool version used
- `rules`: Metadata for all rules executed
- `informationUri`: Link to tool documentation

### Results Array

Each result represents a finding:

```json
{
  "ruleId": "cpp/unbounded-write",
  "ruleIndex": 42,
  "level": "error",
  "message": {
    "text": "This call to 'strcpy' may overflow buffer 'buffer'."
  },
  "locations": [
    {
      "physicalLocation": {
        "artifactLocation": {
          "uri": "src/vulnerable.cpp",
          "uriBaseId": "SRCROOT"
        },
        "region": {
          "startLine": 15,
          "startColumn": 5,
          "endLine": 15,
          "endColumn": 28
        }
      }
    }
  ],
  "codeFlows": [ ... ],
  "relatedLocations": [ ... ],
  "properties": {
    "precision": "high",
    "security-severity": "9.8"
  }
}
```

**Result Fields**:
- `ruleId`: Unique identifier for the rule that generated this finding
- `level`: Severity level (`error`, `warning`, `note`, `none`)
- `message`: Human-readable description
- `locations`: Where the issue was found (file, line, column)
- `codeFlows`: Execution paths leading to the issue
- `relatedLocations`: Additional context locations
- `properties`: Extra metadata (tags, severity scores, etc.)

### Severity Levels

SARIF defines standard severity levels:

| Level     | Meaning                           | Use Case              |
|-----------|-----------------------------------|-----------------------|
| `error`   | Critical security/correctness bug | Must fix              |
| `warning` | Potential issue requiring review  | Should fix            |
| `note`    | Informational finding             | Consider fixing       |
| `none`    | Passed check (for completeness)   | Tracking/metrics      |

### Location Information

Locations pinpoint findings precisely:

```json
"physicalLocation": {
  "artifactLocation": {
    "uri": "src/main.cpp",
    "uriBaseId": "SRCROOT"
  },
  "region": {
    "startLine": 42,
    "startColumn": 10,
    "endLine": 42,
    "endColumn": 25,
    "snippet": {
      "text": "strcpy(buffer, input);"
    }
  },
  "contextRegion": {
    "startLine": 40,
    "endLine": 44,
    "snippet": {
      "text": "void process(char* input) {\n    char buffer[64];\n    strcpy(buffer, input);\n    printf(\"%s\\n\", buffer);\n}"
    }
  }
}
```

**Location Components**:
- `artifactLocation`: File path (relative or absolute)
- `region`: Specific line/column range
- `snippet`: Exact code causing the issue
- `contextRegion`: Surrounding code for context

### Code Flows

Code flows show execution paths:

```json
"codeFlows": [
  {
    "threadFlows": [
      {
        "locations": [
          {
            "location": {
              "message": { "text": "User input received" },
              "physicalLocation": {
                "artifactLocation": { "uri": "src/main.cpp" },
                "region": { "startLine": 10 }
              }
            }
          },
          {
            "location": {
              "message": { "text": "Input passed without validation" },
              "physicalLocation": {
                "artifactLocation": { "uri": "src/main.cpp" },
                "region": { "startLine": 15 }
              }
            }
          },
          {
            "location": {
              "message": { "text": "Unbounded write occurs here" },
              "physicalLocation": {
                "artifactLocation": { "uri": "src/main.cpp" },
                "region": { "startLine": 42 }
              }
            }
          }
        ]
      }
    ]
  }
]
```

**Flow Information**:
- Shows data flow from source to sink
- Explains how tainted data propagates
- Helps understand complex vulnerabilities
- Useful for manual validation

## Working with SARIF Files

### Generating SARIF Output

CodeQL generates SARIF by default:

```bash
# Basic SARIF generation
codeql database analyze my-database \
  codeql/cpp-queries:codeql-suites/cpp-security-and-quality.qls \
  --format=sarif-latest \
  --output=results.sarif

# With additional options
codeql database analyze my-database \
  codeql/cpp-queries:codeql-suites/cpp-security-and-quality.qls \
  --format=sarif-latest \
  --sarif-category=security \
  --sarif-add-baseline-file-info \
  --output=results.sarif

# Multiple output formats
codeql database analyze my-database \
  codeql/cpp-queries \
  --format=sarif-latest \
  --output=results.sarif \
  --format=csv \
  --output=results.csv
```

**Output Options**:
- `--format=sarif-latest`: Use latest SARIF version
- `--sarif-category`: Add category for grouping results
- `--sarif-add-baseline-file-info`: Include baseline metadata
- Multiple formats can be generated simultaneously

### Viewing SARIF Files

**Command Line**:
```bash
# Pretty print with jq
jq . results.sarif | less

# Count total findings
jq '.runs[0].results | length' results.sarif

# List unique rule IDs
jq -r '.runs[0].results[].ruleId' results.sarif | sort | uniq

# Filter by severity
jq '.runs[0].results[] | select(.level == "error")' results.sarif
```

**VS Code**:
- Install "SARIF Viewer" extension
- Open `.sarif` files directly
- Navigate findings interactively
- Jump to code locations

**GitHub**:
- Upload via Code Scanning API
- View in Security tab
- Track trends over time
- Create issues from findings

**Specialized Tools**:
- **SARIF Multitool**: Command-line processing and validation
- **SARIF Web Component**: Web-based viewer
- **Azure DevOps**: Native SARIF support
- **SonarQube**: SARIF import capability

### Processing SARIF with jq

`jq` is powerful for SARIF manipulation:

**Extract Specific Fields**:
```bash
# Get all error-level findings with locations
jq '.runs[0].results[] | 
    select(.level == "error") | 
    {
      rule: .ruleId, 
      file: .locations[0].physicalLocation.artifactLocation.uri,
      line: .locations[0].physicalLocation.region.startLine,
      message: .message.text
    }' results.sarif

# Export to CSV
jq -r '.runs[0].results[] | 
    [
      .ruleId, 
      .level, 
      .locations[0].physicalLocation.artifactLocation.uri,
      .locations[0].physicalLocation.region.startLine,
      .message.text
    ] | @csv' results.sarif > findings.csv
```

**Group and Count**:
```bash
# Count findings by severity
jq '.runs[0].results | 
    group_by(.level) | 
    map({level: .[0].level, count: length})' results.sarif

# Count findings by rule
jq '.runs[0].results | 
    group_by(.ruleId) | 
    map({rule: .[0].ruleId, count: length}) | 
    sort_by(-.count)' results.sarif

# Find most problematic files
jq '.runs[0].results | 
    group_by(.locations[0].physicalLocation.artifactLocation.uri) | 
    map({file: .[0].locations[0].physicalLocation.artifactLocation.uri, 
         issues: length}) | 
    sort_by(-.issues) | 
    limit(10; .[])' results.sarif
```

**Filter and Transform**:
```bash
# Keep only high-precision findings
jq '.runs[0].results |= 
    map(select(.properties.precision == "high" or 
                .properties.precision == "very-high"))' \
    results.sarif > high-confidence.sarif

# Remove specific rule
jq '.runs[0].results |= 
    map(select(.ruleId != "cpp/todo-comment"))' \
    results.sarif > filtered.sarif

# Add custom property
jq '.runs[0].results |= 
    map(.properties.customField = "value")' \
    results.sarif > enhanced.sarif
```

## Alternative Output Formats

### CSV Format

Simple tabular output for spreadsheet analysis:

```bash
codeql database analyze my-database \
  codeql/cpp-queries \
  --format=csv \
  --output=results.csv
```

**CSV Structure**:
```
"Name","Description","Severity","Message","Path","Start line","Start column"
"Unbounded write","Writing to buffer...","error","Call may overflow","src/main.cpp",42,5
```

**Use Cases**:
- Quick spreadsheet analysis
- Simple reporting needs
- Non-technical stakeholders
- Basic trend tracking

**Limitations**:
- No code flow information
- Limited metadata
- No tool interoperability

### SARIF-CSV Hybrid

Convert SARIF to enhanced CSV:

```bash
# Custom CSV with more fields
jq -r '
  ["Rule", "Level", "File", "Line", "Message", "Tags", "Precision"] as $header |
  ($header | @csv),
  (.runs[0].results[] | 
    [
      .ruleId,
      .level,
      .locations[0].physicalLocation.artifactLocation.uri,
      .locations[0].physicalLocation.region.startLine,
      .message.text,
      (.properties.tags // [] | join(";")),
      .properties.precision
    ] | @csv
  )
' results.sarif > detailed.csv
```

### XML Format

For legacy tool integration:

```bash
# Convert SARIF to XML (using sarif-multitool or custom script)
sarif transform results.sarif --output results.xml --format xml
```

### JSON Format (Non-SARIF)

Custom JSON structures for specific needs:

```bash
# Simple JSON summary
jq '{
  total: (.runs[0].results | length),
  errors: ([.runs[0].results[] | select(.level == "error")] | length),
  warnings: ([.runs[0].results[] | select(.level == "warning")] | length),
  by_rule: (.runs[0].results | 
            group_by(.ruleId) | 
            map({rule: .[0].ruleId, count: length}))
}' results.sarif > summary.json
```

## Integration Patterns

### GitHub Code Scanning

Upload SARIF results to GitHub:

```yaml
# .github/workflows/codeql.yml
name: CodeQL Analysis

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  analyze:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: cpp
    
    - name: Build
      run: |
        mkdir build && cd build
        cmake ..
        make
    
    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
      with:
        category: "/language:cpp"
```

**Manual Upload**:
```bash
# Generate SARIF
codeql database analyze my-db \
  codeql/cpp-queries \
  --format=sarif-latest \
  --output=results.sarif

# Upload to GitHub
gh api repos/{owner}/{repo}/code-scanning/sarifs \
  -f commit_sha="$(git rev-parse HEAD)" \
  -f ref="refs/heads/$(git branch --show-current)" \
  -f sarif="$(cat results.sarif | gzip | base64)"
```

### Azure DevOps

Publish SARIF to Azure Pipelines:

```yaml
# azure-pipelines.yml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: CodeQL@1
  inputs:
    language: 'cpp'
    
- script: |
    codeql database analyze $(Build.SourcesDirectory)/codeql-db \
      codeql/cpp-queries \
      --format=sarif-latest \
      --output=$(Build.ArtifactStagingDirectory)/results.sarif
  displayName: 'Run CodeQL Analysis'

- task: PublishBuildArtifacts@1
  inputs:
    PathtoPublish: '$(Build.ArtifactStagingDirectory)/results.sarif'
    ArtifactName: 'CodeQL Results'
```

### GitLab CI/CD

```yaml
# .gitlab-ci.yml
codeql_scan:
  stage: test
  image: ghcr.io/github/codeql-action/codeql-runner:latest
  script:
    - codeql database create codeql-db --language=cpp
    - codeql database analyze codeql-db 
        codeql/cpp-queries 
        --format=sarif-latest 
        --output=results.sarif
  artifacts:
    reports:
      sast: results.sarif
    paths:
      - results.sarif
    expire_in: 1 week
```

### Jenkins

```groovy
pipeline {
    agent any
    
    stages {
        stage('CodeQL Analysis') {
            steps {
                sh '''
                    codeql database create codeql-db --language=cpp
                    codeql database analyze codeql-db \
                        codeql/cpp-queries \
                        --format=sarif-latest \
                        --output=results.sarif
                '''
                
                publishHTML([
                    reportName: 'CodeQL Results',
                    reportDir: '.',
                    reportFiles: 'results.sarif',
                    keepAll: true
                ])
                
                archiveArtifacts artifacts: 'results.sarif'
            }
        }
    }
}
```

### SonarQube Integration

Convert and import SARIF to SonarQube:

```bash
# Using sonar-sarif-converter (hypothetical)
sonar-sarif-converter \
  --input results.sarif \
  --output sonar-import.json

# Import to SonarQube
sonar-scanner \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=src \
  -Dsonar.externalIssuesReportPaths=sonar-import.json
```

## Advanced SARIF Usage

### Baselining and Suppression

Track known issues to focus on new findings:

```bash
# Create baseline
codeql database analyze my-db codeql/cpp-queries \
  --format=sarif-latest \
  --output=baseline.sarif

# Compare with new scan
codeql database analyze my-db codeql/cpp-queries \
  --format=sarif-latest \
  --output=current.sarif

# Find new issues (using jq)
comm -13 \
  <(jq -r '.runs[0].results[].ruleId + ":" + 
           .locations[0].physicalLocation.artifactLocation.uri + ":" + 
           (.locations[0].physicalLocation.region.startLine | tostring)' \
     baseline.sarif | sort) \
  <(jq -r '.runs[0].results[].ruleId + ":" + 
           .locations[0].physicalLocation.artifactLocation.uri + ":" + 
           (.locations[0].physicalLocation.region.startLine | tostring)' \
     current.sarif | sort)
```

### In-Source Suppressions

CodeQL supports **inline alert suppression** using special comments in your 
source code. This is the recommended approach for managing false positives 
and intentional exceptions.

#### C/C++ Suppressions

Use `// lgtm [rule-id]` or `// codeql [rule-id]` comments:

```cpp
// Suppress specific rule
void legacy_function() {
    char buffer[64];
    // lgtm [cpp/unbounded-write]
    strcpy(buffer, user_input);  // Suppressed: legacy code, refactor planned
}

// Suppress with justification
void process_data(char* input) {
    // codeql [cpp/potentially-dangerous-function] - Input validated by caller
    system(input);
}

// Suppress on previous line
char* get_data() {
    // lgtm [cpp/return-stack-allocated-memory]
    return local_buffer;
}

// Suppress multiple rules
void risky_operation() {
    // lgtm [cpp/unbounded-write, cpp/no-space-for-terminator]
    strcpy(dst, src);
}
```

**Comment Formats**:
- `// lgtm [rule-id]` - Original LGTM.com format (still supported)
- `// codeql [rule-id]` - Preferred CodeQL format
- Must appear on the line **before** or **on the same line** as the alert

#### Rust Suppressions

```rust
// Suppress specific query
fn unsafe_operation() {
    // codeql [rust/unsafe-block]
    unsafe {
        raw_pointer.write(value);
    }
}

// With justification comment
pub fn process(data: &str) {
    // codeql [rust/path-injection] - Path is validated by check_path()
    std::fs::read_to_string(data).unwrap();
}
```

#### JavaScript/TypeScript Suppressions

```javascript
// Suppress alert
function processInput(userInput) {
    // lgtm [js/incomplete-sanitization]
    const cleaned = userInput.replace(/<script>/g, '');
    return cleaned;
}

// Block-level suppression
function legacyCode() {
    // lgtm
    eval(userProvidedCode);  // All alerts on this line suppressed
}
```

#### Python Suppressions

```python
def process_file(filename):
    # lgtm [py/path-injection]
    with open(filename) as f:  # Suppressed: filename from trusted config
        return f.read()

# Suppress command injection
def run_command(cmd):
    # codeql [py/command-injection] - Command constructed from safe constants
    os.system(cmd)
```

#### Suppression Best Practices

**DO**:
- ✅ Add justification comments explaining why suppression is needed
- ✅ Include ticket/issue numbers for tracking
- ✅ Review suppressions periodically
- ✅ Use specific rule IDs rather than suppressing all alerts
- ✅ Document suppression policies in your team guidelines

**DON'T**:
- ❌ Suppress alerts without understanding the security implications
- ❌ Use blanket suppressions (`// lgtm` without rule ID)
- ❌ Suppress in production-critical security code without peer review
- ❌ Leave suppressions indefinitely without revisiting

#### SARIF Representation

Suppressed alerts appear in SARIF with suppression metadata:

```json
{
  "ruleId": "cpp/unbounded-write",
  "message": { "text": "This call may overflow..." },
  "suppressions": [
    {
      "kind": "inSource",
      "location": {
        "physicalLocation": {
          "artifactLocation": { "uri": "src/main.cpp" },
          "region": { "startLine": 42 }
        }
      },
      "justification": "lgtm [cpp/unbounded-write]"
    }
  ],
  "locations": [ ... ]
}
```

**Suppression Fields**:
- `kind`: Always "inSource" for comment-based suppressions
- `location`: Where the suppression comment appears
- `justification`: The actual comment text
- `status`: Can be "accepted" or "rejected"

#### Query Suppressions in SARIF

Filter suppressed results:

```bash
# Remove suppressed alerts from SARIF
jq '.runs[0].results |= 
    map(select(.suppressions == null or .suppressions | length == 0))' \
    results.sarif > unsuppressed.sarif

# Show only suppressed alerts
jq '.runs[0].results |= 
    map(select(.suppressions != null and .suppressions | length > 0))' \
    results.sarif > suppressed.sarif

# Count suppressions
jq '[.runs[0].results[] | 
     select(.suppressions != null and .suppressions | length > 0)] | 
     length' results.sarif
```

#### Finding Suppression Comments

Search for suppressions in your codebase:

```bash
# Find all lgtm/codeql comments
grep -rn "// lgtm\|// codeql" src/

# Find suppressions with specific rule
grep -rn "lgtm \[cpp/unbounded-write\]" src/

# List all suppressed rules
grep -roh "lgtm \[[^]]*\]" src/ | sort | uniq -c
```

#### External Suppression Files

For cases where in-source comments aren't appropriate, use external 
suppression files:

**suppressions.json**:
```json
{
  "version": "1.0",
  "suppressions": [
    {
      "ruleId": "cpp/unbounded-write",
      "path": "src/legacy.cpp",
      "lineNumber": 100,
      "justification": "Legacy code, scheduled for refactor in Q2 2025",
      "expiresOn": "2025-06-30",
      "approvedBy": "security-team"
    },
    {
      "ruleId": "cpp/potentially-dangerous-function",
      "path": "vendor/**",
      "justification": "Third-party code, vendor responsibility",
      "permanent": true
    }
  ]
}
```

Apply external suppressions:

```bash
# Filter SARIF using suppression file
jq --slurpfile suppressions suppressions.json '
  .runs[0].results |= map(
    . as $result |
    if any($suppressions[0].suppressions[];
           .ruleId == $result.ruleId and
           ($result.locations[0].physicalLocation.artifactLocation.uri | 
            test(.path)))
    then 
      .suppressions = [{
        kind: "external",
        justification: (
          $suppressions[0].suppressions[] |
          select(.ruleId == $result.ruleId) |
          .justification
        )
      }]
    else .
    end
  )
' results.sarif > filtered.sarif
```

#### Suppression Auditing

Track and review suppressions:

```bash
# Generate suppression report
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
' results.sarif > suppression-audit.csv

# Count suppressions by rule
jq '.runs[0].results[] |
    select(.suppressions != null) |
    .ruleId' results.sarif | sort | uniq -c | sort -rn

# Find suppressions without justification
jq -r '.runs[0].results[] |
    select(.suppressions != null) |
    select(.suppressions[0].justification | 
           test("lgtm|codeql") and 
           (test("because|reason|ticket|issue|planned") | not)) |
    "\(.locations[0].physicalLocation.artifactLocation.uri):\(.locations[0].physicalLocation.region.startLine) - \(.ruleId)"' \
    results.sarif
```

#### GitHub Code Scanning Integration

Suppressions are automatically respected in GitHub Code Scanning:

- Suppressed alerts don't appear in the Security tab
- Suppressions are visible in the code review interface
- Hovering over suppressed code shows the justification
- SARIF upload includes suppression metadata

**Example GitHub Actions with Suppressions**:
```yaml
- name: Run CodeQL Analysis
  uses: github/codeql-action/analyze@v3
  # Suppressions in code are automatically handled

- name: Upload SARIF (includes suppressions)
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: results.sarif
    # Suppressed alerts marked but still tracked
```

#### Temporary vs Permanent Suppressions

**Temporary Suppressions** (with expiry):
```cpp
// codeql [cpp/unbounded-write] TODO(security-123): Fix by 2025-Q2
strcpy(buffer, input);
```

**Permanent Suppressions** (false positives):
```cpp
// codeql [cpp/return-stack-allocated-memory] - Static storage, not stack
static char global_buffer[1024];
return global_buffer;
```

Track temporary suppressions:
```bash
# Find TODO suppressions
grep -rn "lgtm.*TODO\|codeql.*TODO" src/

# Extract expiry dates
grep -roh "by [0-9-]*" src/ | sort | uniq
```

### Merging Multiple SARIF Files

Combine results from multiple scans:

```bash
# Merge two SARIF files
jq -s '
  {
    version: .[0].version,
    "$schema": .[0]."$schema",
    runs: [.[0].runs[0], .[1].runs[0]]
  }
' results1.sarif results2.sarif > merged.sarif

# Merge with deduplication
jq -s '
  {
    version: .[0].version,
    "$schema": .[0]."$schema",
    runs: [{
      tool: .[0].runs[0].tool,
      results: ([.[].runs[].results[]] | unique_by(.ruleId + 
               .locations[0].physicalLocation.artifactLocation.uri +
               (.locations[0].physicalLocation.region.startLine | tostring)))
    }]
  }
' results*.sarif > combined.sarif
```

### Custom Reporting

Generate HTML reports from SARIF:

```bash
# Using sarif-html-reporter (example tool)
npm install -g @microsoft/sarif-html-reporter

sarif-html-reporter \
  --input results.sarif \
  --output report.html \
  --title "CodeQL Security Scan"

# Custom HTML with jq + template
jq -r '
  .runs[0].results[] | 
  "<tr>
    <td>\(.ruleId)</td>
    <td>\(.level)</td>
    <td>\(.locations[0].physicalLocation.artifactLocation.uri)</td>
    <td>\(.locations[0].physicalLocation.region.startLine)</td>
    <td>\(.message.text)</td>
  </tr>"
' results.sarif | \
  (echo "<html><body><table><tr><th>Rule</th><th>Level</th><th>File</th><th>Line</th><th>Message</th></tr>"; cat; echo "</table></body></html>") \
  > report.html
```

### Metrics and Dashboards

Extract metrics for dashboards:

```bash
# Generate metrics JSON
jq '{
  scan_date: now | strftime("%Y-%m-%d"),
  total_findings: (.runs[0].results | length),
  by_severity: (
    .runs[0].results | 
    group_by(.level) | 
    map({level: .[0].level, count: length}) |
    from_entries
  ),
  by_precision: (
    .runs[0].results | 
    group_by(.properties.precision // "unknown") |
    map({precision: .[0].properties.precision // "unknown", count: length}) |
    from_entries
  ),
  top_rules: (
    .runs[0].results |
    group_by(.ruleId) |
    map({rule: .[0].ruleId, count: length}) |
    sort_by(-.count) |
    limit(10; .[])
  ),
  files_affected: (
    .runs[0].results |
    map(.locations[0].physicalLocation.artifactLocation.uri) |
    unique |
    length
  )
}' results.sarif > metrics.json

# Time series tracking
echo "$(date +%s),$(jq '.runs[0].results | length' results.sarif)" \
  >> timeseries.csv
```

## Best Practices

### File Organization

```
project/
├── codeql-results/
│   ├── current/
│   │   ├── results.sarif
│   │   └── metadata.json
│   ├── baseline/
│   │   └── baseline.sarif
│   ├── history/
│   │   ├── 2024-11-01-results.sarif
│   │   └── 2024-11-10-results.sarif
│   └── reports/
│       ├── compliance-report.html
│       └── metrics.json
```

### Version Control

**Do Store**:
- Baseline SARIF files for comparison
- Suppression lists
- CI/CD configuration
- Processing scripts

**Don't Store**:
- Large current scan results (use artifacts instead)
- Sensitive path information
- Complete historical scans (use summary metrics)

### Performance Optimization

**Reduce SARIF Size**:
```bash
# Remove unnecessary fields
jq 'del(.runs[0].tool.driver.rules[].help)' results.sarif \
  > compact.sarif

# Keep only errors and warnings
jq '.runs[0].results |= 
    map(select(.level == "error" or .level == "warning"))' \
  results.sarif > critical-only.sarif
```

**Compress for Storage**:
```bash
# Gzip compression
gzip -9 results.sarif

# For CI artifacts
tar -czf results.tar.gz results.sarif metrics.json
```

### Security Considerations

- **Sanitize Paths**: Remove absolute paths that expose system structure
- **Redact Secrets**: Ensure no secrets appear in code snippets
- **Access Control**: Restrict SARIF file access (may contain vulnerability details)
- **Audit Trail**: Log who accessed and modified SARIF files

```bash
# Sanitize paths
jq '(.runs[0].results[].locations[].physicalLocation.artifactLocation.uri |= 
     sub("^/home/user/"; ""))' \
  results.sarif > sanitized.sarif
```

## Troubleshooting

### Invalid SARIF

**Validate SARIF files**:
```bash
# Using sarif-multitool
sarif validate results.sarif

# Using JSON schema validation
ajv validate \
  -s sarif-schema-2.1.0.json \
  -d results.sarif
```

### Empty Results

If SARIF contains no findings:
- Verify queries ran successfully (check logs)
- Confirm database contains code (`codeql database info`)
- Check if queries are applicable to your code
- Review query suite selection

### Large SARIF Files

For very large files:
- Stream processing with `jq --stream`
- Split by severity or rule
- Archive old results
- Use summary metrics instead of full files

```bash
# Stream large file
jq --stream 'select(length == 2 and .[0][1] == "ruleId") | .[1]' \
  huge-results.sarif | sort | uniq -c
```

## SARIF Features: CodeQL Support

The SARIF 2.1.0 specification defines many features. Here's what CodeQL 
actually uses and what it doesn't:

### ✅ Features Used by CodeQL

CodeQL generates SARIF files with these components:

**Core Structure**:
- ✅ `runs[]` - Analysis run container
- ✅ `tool.driver` - Tool metadata (name, version, organization, rules)
- ✅ `results[]` - Array of findings
- ✅ `artifacts[]` - List of files analyzed
- ✅ `invocations[]` - Execution information (success/failure, notifications)

**Result Components**:
- ✅ `ruleId` - Unique identifier for the rule
- ✅ `message` - Human-readable description
- ✅ `locations[]` - Physical file locations with line/column
- ✅ `level` - Severity (`error`, `warning`, `note`)
- ✅ `partialFingerprints` - Stable identifiers for tracking across scans
  - `primaryLocationLineHash` - Hash of the source line
  - `primaryLocationStartColumnFingerprint` - Column position fingerprint
- ✅ `codeFlows[]` - Data flow paths from source to sink
- ✅ `relatedLocations[]` - Additional context locations
- ✅ `suppressions[]` - In-source alert suppressions (`// lgtm`, `// codeql`)
- ✅ `properties` - Custom metadata (tags, precision, security-severity)

**Rule Metadata**:
- ✅ `id`, `name`, `shortDescription`, `fullDescription`
- ✅ `help` - Detailed explanation with examples
- ✅ `properties.tags[]` - Classification tags (security, external/cwe/cwe-###)
- ✅ `properties.precision` - Confidence level (high, medium, low, very-high)
- ✅ `properties.problem.severity` - Issue severity
- ✅ `properties.security-severity` - CVSS-like score (0-10)

**Execution Details**:
- ✅ `invocations[].executionSuccessful` - Whether scan completed
- ✅ `invocations[].toolExecutionNotifications` - Warnings/errors during scan
- ✅ `tool.driver.notifications[]` - Tool-level diagnostic messages

### ❌ Features NOT Used by CodeQL

The following SARIF 2.1.0 features are **not currently used** by CodeQL:

**Automated Fixes**:
- ❌ `fixes[]` - Suggested code fixes for automated remediation
- ❌ `fix.artifactChanges[]` - Specific text replacements
- *Note*: IDEs may offer fixes, but CodeQL SARIF doesn't include them

**Logical Locations**:
- ❌ `logicalLocations[]` - Symbolic locations (namespace, class, function)
- *Use*: Physical locations only (file paths, line numbers)

**Graphs and Relationships**:
- ❌ `graphs[]` - Explicit graph representations
- ❌ `graphTraversals[]` - Path descriptions through graphs
- *Note*: `codeFlows` serve similar purpose for data flow

**Taxonomies**:
- ❌ `taxonomies[]` - Classification schemes (CWE, CERT, etc.)
- *Note*: Tags encode this information instead (e.g., `external/cwe/cwe-787`)

**Advanced Invocation Details**:
- ❌ `invocations[].startTimeUtc` - Scan start time
- ❌ `invocations[].endTimeUtc` - Scan end time
- ❌ `invocations[].exitCode` - Process exit code
- ❌ `invocations[].commandLine` - Exact command executed
- ❌ `invocations[].environmentVariables` - Environment during scan
- ❌ `invocations[].workingDirectory` - Directory where scan ran
- *Note*: Basic success/failure info only via `executionSuccessful`

**ThreadFlow Properties**:
- ❌ `threadFlowLocation.executionOrder` - Step ordering in execution
- ❌ `threadFlowLocation.nestingLevel` - Call stack depth
- ❌ `threadFlowLocation.importance` - Relative importance of step
- *Note*: CodeQL code flows are simpler, showing just locations

**Result Provenance**:
- ❌ `provenance` - Origin tracking in complex pipelines
- ❌ `conversionSources[]` - If result came from conversion

**Stable Fingerprints**:
- ❌ `fingerprints` - Fully stable identifiers across code changes
- ✅ `partialFingerprints` - Hash-based tracking (what CodeQL uses)
- *Note*: Partial fingerprints sufficient for most use cases

**Web Requests/Responses**:
- ❌ `webRequest`, `webResponse` - HTTP traffic for web scanners
- *Use*: Not applicable to static analysis

### Why These Limitations?

1. **Simplicity**: CodeQL focuses on essential information
2. **Performance**: Smaller SARIF files are faster to process
3. **Compatibility**: Core features work everywhere
4. **Evolution**: Features may be added in future versions

### Workarounds

**For Fixes**: Use IDE extensions or custom scripts to generate fixes based on rule IDs

**For Logical Locations**: Parse physical locations and infer from file structure

**For Taxonomies**: Use `properties.tags[]` which encodes CWE, CERT, etc.

**For Timing**: Run CodeQL with `--verbosity=progress` and parse logs

**For Full Fingerprints**: Hash `partialFingerprints` with file path for stability

### Example: Checking SARIF Features

```bash
# Check if CodeQL SARIF has fixes
jq '.runs[0].results[] | has("fixes")' results.sarif | sort | uniq
# Output: false

# Check for partial fingerprints (used)
jq '.runs[0].results[0].partialFingerprints' results.sarif
# Output: {"primaryLocationLineHash": "...", "primaryLocationStartColumnFingerprint": "..."}

# Check for logical locations
jq '.runs[0].results[] | has("logicalLocations")' results.sarif | sort | uniq
# Output: false

# Check invocation details
jq '.runs[0].invocations[0] | keys' results.sarif
# Output: ["executionSuccessful", "toolExecutionNotifications"]
```

## Next Steps

Now that you understand SARIF output:

1. **Practice**: Complete Lab 08 exercises with real SARIF files
2. **Integration**: Set up CI/CD pipeline with SARIF upload
3. **Automation**: Create custom processing scripts for your workflow
4. **Advanced**: Learn to write custom queries (Tutorial 11)

## Additional Resources

- **SARIF Specification**: https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html
- **SARIF Tutorials**: https://github.com/microsoft/sarif-tutorials
- **GitHub Code Scanning**: https://docs.github.com/en/code-security/code-scanning
- **SARIF Multitool**: https://github.com/microsoft/sarif-sdk
- **jq Manual**: https://stedolan.github.io/jq/manual/

---

**Next**: [Advanced Configuration](09-advanced-config.md) | 
**Lab**: [SARIF Processing Exercises](lab/08-sarif-output/)
