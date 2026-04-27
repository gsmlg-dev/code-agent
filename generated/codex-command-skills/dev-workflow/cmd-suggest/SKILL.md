---
name: "cmd-suggest"
description: "Analyze repository and suggest improvements"
---

# /suggest

Agent skill wrapper for the Claude command `/suggest`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Please analyze this repository comprehensively and create suggest.md with:

1. Code Quality Issues
   - Code smells and anti-patterns
   - Duplicate code
   - Overly complex functions

2. Performance Optimizations
   - Database query improvements
   - Caching opportunities
   - Algorithm efficiency

3. Architecture Suggestions
   - Design pattern improvements
   - Separation of concerns
   - Modularity enhancements

4. Security Issues
   - Vulnerabilities
   - Best practices violations

5. Testing Improvements
   - Missing test coverage
   - Test quality issues

6. Documentation Gaps
   - Missing or outdated docs
   - Code comments needed

Format each suggestion with:
- Issue description
- Current code example
- Proposed solution
- Priority (High/Medium/Low)
- Estimated effort

Write all findings to suggest.md
