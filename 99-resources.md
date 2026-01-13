# 🔗 Useful Resources

This document provides a curated collection of resources to help you
learn and work with CodeQL effectively. These resources cover official
documentation, community contributions, tooling, and specific coding
standards support.

---

## 📚 Official Documentation

### Core Documentation

- **[CodeQL Documentation](https://codeql.github.com/docs/)**
  - Comprehensive official documentation
  - Language reference, API docs, and tutorials
  - Best starting point for learning CodeQL

- **[CodeQL CLI Manual](https://codeql.github.com/docs/codeql-cli/)**
  - Complete CLI command reference
  - Database creation and query execution
  - Advanced configuration options

- **[QL Language Reference](https://codeql.github.com/docs/ql-language-reference/)**
  - Syntax and semantics of the QL language
  - Type system and predicates
  - Query writing fundamentals

### VS Code Extension

- **[CodeQL for VS Code](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-codeql)**
  - Official VS Code extension
  - Interactive query development
  - Database browsing and result visualization

- **[VS Code Extension Docs](https://codeql.github.com/docs/codeql-for-visual-studio-code/)**
  - Setup and configuration guide
  - Feature overview and keyboard shortcuts
  - Debugging and testing queries

---

## 🐙 GitHub Repositories

### Core CodeQL Repositories

- **[github/codeql](https://github.com/github/codeql)**
  - Standard libraries for all supported languages
  - Built-in query suites
  - Language-specific APIs and classes

- **[github/codeql-cli-binaries](https://github.com/github/codeql-cli-binaries)**
  - Official CodeQL CLI releases
  - Download links for all platforms
  - Release notes and changelogs

- **[github/codeql-action](https://github.com/github/codeql-action)**
  - GitHub Actions for CodeQL
  - CI/CD integration examples
  - Workflow templates

### Coding Standards

- **[github/codeql-coding-standards](https://github.com/github/codeql-coding-standards)**
  - MISRA C:2012, C++:2008, C++:2023 queries
  - CERT C/C++ secure coding queries
  - AUTOSAR C++14 guidelines
  - Compliance reporting tools

### Language-Specific Resources

- **[github/codeql-go](https://github.com/github/codeql-go)**
  - Go language support for CodeQL
  - Community-contributed queries

- **[github/codeql-kotlin](https://github.com/github/codeql-kotlin)**
  - Kotlin language support
  - Android security queries

---

## 🎓 Learning Resources

### Tutorials & Guides

- **[CodeQL Zero to Hero](https://github.com/GitHubSecurityLab/codeql-zero-to-hero)**
  - Beginner-friendly tutorial series
  - Step-by-step query development
  - Real-world examples

- **[GitHub Security Lab](https://securitylab.github.com/)**
  - Research and vulnerability discoveries
  - Advanced query techniques
  - Security best practices

- **[CodeQL CTF Challenges](https://securitylab.github.com/ctf/)**
  - Capture The Flag challenges using CodeQL
  - Hands-on learning through gamification
  - Progressive difficulty levels

### Video Content

- **[GitHub CodeQL YouTube Playlist](https://www.youtube.com/c/GitHub/search?query=codeql)**
  - Official GitHub videos on CodeQL
  - Conference talks and demos
  - Feature announcements

- **[GitHub Universe CodeQL Sessions](https://githubuniverse.com/)**
  - Annual conference presentations
  - Deep dives into advanced topics
  - Community showcases

---

## 🛠️ Tools & Extensions

### Analysis Tools

- **[SARIF Viewer](https://marketplace.visualstudio.com/items?itemName=MS-SarifVSCode.sarif-viewer)**
  - VS Code extension for viewing SARIF files
  - Result navigation and filtering
  - Integration with CodeQL results

- **[SARIF Multitool](https://github.com/microsoft/sarif-sdk)**
  - Command-line tool for SARIF processing
  - Merge, validate, and transform SARIF files
  - Baselining and result management

- **[jq](https://stedolan.github.io/jq/)**
  - JSON processor for SARIF analysis
  - Filtering and transforming results
  - Scripting and automation

### CI/CD Integration

- **[github/super-linter](https://github.com/github/super-linter)**
  - Multi-language linter including CodeQL
  - GitHub Actions ready
  - Comprehensive code quality checking

- **[GitLab CodeQL Template](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Security/SAST.gitlab-ci.yml)**
  - GitLab CI integration example
  - SAST pipeline configuration
  - Security scanning automation

---

## 📖 Coding Standards Resources

### MISRA

- **[MISRA Official Website](https://www.misra.org.uk/)**
  - MISRA C and C++ standard documentation
  - Purchase official guideline documents
  - Training and certification

- **[MISRA Compliance:2020](https://www.misra.org.uk/compliance/)**
  - Guidelines for demonstrating compliance
  - Documentation requirements
  - Deviation process

- **[MISRA C++:2023 Summary](https://www.misra.org.uk/misra-c-plus-plus-2023/)**
  - Latest C++ guidelines overview
  - Key changes from previous versions
  - Supported by CodeQL coding standards

### CERT

- **[SEI CERT C Coding Standard](https://wiki.sei.cmu.edu/confluence/display/c/SEI+CERT+C+Coding+Standard)**
  - Complete C coding standard
  - Rule descriptions and examples
  - Risk assessments and recommendations

- **[SEI CERT C++ Coding Standard](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682)**
  - C++ secure coding guidelines
  - Common vulnerability patterns
  - Best practices and mitigation strategies

- **[CERT Secure Coding](https://www.securecoding.cert.org/)**
  - Training and certification programs
  - Additional language standards
  - Research and publications

---

## 👥 Community Resources

### Discussion Forums

- **[GitHub Community Discussions](https://github.com/github/codeql/discussions)**
  - Official CodeQL community forum
  - Questions, feature requests, and announcements
  - Help from maintainers and community

- **[Stack Overflow - CodeQL Tag](https://stackoverflow.com/questions/tagged/codeql)**
  - Community Q&A for CodeQL
  - Searchable archive of solutions
  - Active community support

### Social Media

- **[GitHub Security Lab Twitter](https://twitter.com/ghsecuritylab)**
  - Latest security research using CodeQL
  - New query announcements
  - Community highlights

- **[GitHub Security Blog](https://github.blog/category/security/)**
  - In-depth articles on security topics
  - CodeQL case studies
  - Best practices and guides

---

## 📊 Query Libraries & Packs

### Query Packs

- **[codeql/cpp-queries](https://github.com/github/codeql/tree/main/cpp/ql/src)**
  - Standard C/C++ security queries
  - Code quality checks
  - Common vulnerability patterns

- **[codeql/rust-queries](https://github.com/github/codeql/tree/main/rust/ql/src)**
  - Rust-specific queries
  - Memory safety checks
  - Ownership and borrowing issues

- **[codeql/python-queries](https://github.com/github/codeql/tree/main/python/ql/src)**
  - Python security and quality queries
  - SQL injection and XSS detection
  - Common Python anti-patterns

### Custom Query Collections

- **[advanced-security/codeql-queries](https://github.com/advanced-security/codeql-queries)**
  - Community-contributed custom queries
  - Language-specific collections
  - Experimental and research queries

- **[GitHubSecurityLab/CodeQL-Community-Packs](https://github.com/GitHubSecurityLab/CodeQL-Community-Packs)**
  - Curated community query packs
  - Specific vulnerability classes
  - Best-practice examples

---

## 🔬 Research & Papers

### Academic Publications

- **[Original Semmle QL Paper (OOPSLA 2016)](https://dl.acm.org/doi/10.1145/2983990.2984008)**
  - "QL: Object-oriented Queries on Relational Data"
  - Theoretical foundations of CodeQL
  - Language design and semantics

- **[CodeQL for Security Research](https://securitylab.github.com/research/)**
  - GitHub Security Lab research publications
  - Vulnerability discovery case studies
  - Novel query techniques

### Conference Talks

- **[GitHub Universe](https://githubuniverse.com/)**
  - Annual conference with CodeQL content
  - Advanced workshops and training
  - Community networking

- **[DEF CON & Black Hat](https://www.defcon.org/)**
  - Security conference presentations
  - CodeQL in security research
  - Real-world vulnerability findings

---

## 🚀 Advanced Topics

### Performance Optimization

- **[Query Performance Guide](https://codeql.github.com/docs/writing-codeql-queries/query-performance/)**
  - Optimizing query execution
  - Database tuning tips
  - Profiling and debugging

### Language Development

- **[Adding Language Support](https://codeql.github.com/docs/codeql-language-guides/)**
  - Creating extractors for new languages
  - Defining AST schemas
  - Writing language libraries

### Custom Standards

- **[Creating Query Suites](https://codeql.github.com/docs/codeql-cli/creating-codeql-query-suites/)**
  - Query suite definition language
  - Filtering and customization
  - Organization-specific standards

---

## 📝 Additional Resources

### SARIF Specification

- **[SARIF Official Spec](https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html)**
  - Complete SARIF format specification
  - Schema definition
  - Best practices for producers/consumers

- **[SARIF Tutorials](https://github.com/microsoft/sarif-tutorials)**
  - Learning resources for SARIF
  - Sample files and validators
  - Integration examples

### License Information

- **[CodeQL License](https://github.com/github/codeql-cli-binaries/blob/main/LICENSE.md)**
  - Free for research and open-source
  - Enterprise licensing options
  - Terms and conditions

---

## 🎯 Quick Links Summary

| Category | Resource | URL |
|----------|----------|-----|
| **Official Docs** | CodeQL Documentation | <https://codeql.github.com/docs/> |
| **CLI** | CodeQL CLI Releases | <https://github.com/github/codeql-cli-binaries> |
| **Queries** | Standard Library | <https://github.com/github/codeql> |
| **Standards** | Coding Standards | <https://github.com/github/codeql-coding-standards> |
| **Learning** | Zero to Hero | <https://github.com/GitHubSecurityLab/codeql-zero-to-hero> |
| **Community** | Discussions | <https://github.com/github/codeql/discussions> |
| **MISRA** | Official Website | <https://www.misra.org.uk/> |
| **CERT** | C Standard | <https://wiki.sei.cmu.edu/confluence/display/c/> |
| **SARIF** | Specification | <https://docs.oasis-open.org/sarif/sarif/v2.1.0/> |

---

## 📫 Getting Help

If you're stuck or have questions:

1. **Check the documentation**: Start with the official CodeQL docs
2. **Search discussions**: Look for similar questions in GitHub Discussions
3. **Ask the community**: Post in GitHub Discussions or Stack Overflow
4. **Report issues**: File bug reports in the appropriate GitHub repository
5. **Join events**: Attend GitHub Universe or local meetups

Remember: The CodeQL community is welcoming and helpful. Don't hesitate
to ask questions!

---

*Last updated: January 2026*
