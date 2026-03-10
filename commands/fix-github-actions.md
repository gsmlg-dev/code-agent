---
description: Fix GitHub Actions failures in current PR iteratively
agent: debugger
arguments:
  - name: max_iterations
    description: Maximum number of fix iterations (default 5)
    required: false
---

Fix GitHub Actions failures in the current pull request through iterative testing.

## Process Overview

This is iteration {{ iteration_number | default: "1" }} of fixing GitHub Actions failures.

## Steps

### 1. Check Current PR Status

First, identify the current branch and PR:
```bash
# Get current branch
git branch --show-current

# Check PR status
gh pr status

# Get detailed PR checks
gh pr checks
```

### 2. Analyze Action Failures
```bash
# View failed action details
gh run view --log-failed

# Or view specific workflow run
gh run view <run-id> --log-failed
```

Analyze the failure logs to identify:
- Which job(s) failed
- What step(s) failed
- Error messages and stack traces
- Whether it's a test failure, build failure, lint failure, etc.

### 3. Categorize the Failure

Identify the type of failure:

**Test Failures**
- Unit test failures
- Integration test failures  
- E2E test failures
- Elixir: `mix test` failures
- Check test output for specific failing tests

**Build Failures**
- Compilation errors
- Dependency issues
- Missing environment variables
- Configuration problems

**Lint/Format Failures**
- Code style violations
- Format check failures
- Elixir: `mix format --check-formatted`
- Linter errors (credo, dialyzer, etc.)

**Other Failures**
- Security scans
- Coverage thresholds
- Deploy failures
- Custom script failures

### 4. Fix the Issues

Based on the failure type, apply appropriate fixes:

**For Test Failures:**
- Fix the failing tests or implementation code
- Update test data, mocks, or fixtures
- Ensure tests pass locally: `mix test` (for Elixir)

**For Build Failures:**
- Fix compilation errors
- Update dependencies in `mix.exs` or similar
- Check for missing configuration

**For Lint/Format Failures:**
- Run formatter: `mix format` (for Elixir)
- Fix linter issues: `mix credo --strict`
- Update code to meet style guidelines

**For Other Failures:**
- Address specific issues based on logs
- Update CI configuration if needed (`.github/workflows/*.yml`)

### 5. Commit and Push Changes
```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "fix: resolve GitHub Actions failure - [brief description]

- [Detail what was fixed]
- [Reference to error or issue]

Fixes CI run: [link or run ID if applicable]"

# Push to PR branch
git push origin HEAD
```

### 6. Wait for Actions to Complete
```bash
# Watch the new run
gh run watch

# Or check status
gh pr checks --watch
```

### 7. Report Status

After pushing, provide a summary:
```
## Fix Iteration Summary

### Issues Found
- [List of issues identified]

### Fixes Applied  
- [File/module changed]: [What was fixed]
- [File/module changed]: [What was fixed]

### Commit
- SHA: [commit hash]
- Message: [commit message]

### Next Steps
{{ if not all_checks_passed }}
The actions are now running. Wait for completion and check results.

If failures persist:
1. Run this command again to analyze new failures
2. The cycle will repeat until all checks pass

Command to continue:
`claude-code fix-github-actions {{ max_iterations }}`
{{ else }}
✅ All GitHub Actions checks passed!
PR is ready for review/merge.
{{ endif }}
```

## Important Rules

**DO:**
- Analyze logs carefully before making changes
- Fix root causes, not just symptoms
- Test fixes locally before pushing when possible
- Write clear commit messages
- Fix multiple related issues in one commit when appropriate

**DO NOT:**
- Skip or disable failing tests without human approval
- Modify CI configuration to bypass checks without approval
- Push untested changes
- Make unrelated changes
- Force push unless explicitly instructed

## When to Stop and Ask

Stop and request human review if:

- Same failure occurs 3+ times despite different fixes
- Failure is due to external service/infrastructure issues
- Fix requires significant architectural changes
- CI configuration appears to need updates
- Credentials or secrets seem to be the issue
- Multiple unrelated failures need prioritization decisions

## Verification Checklist

Before pushing each fix, verify:

- [ ] Issue root cause identified from logs
- [ ] Fix addresses the root cause
- [ ] Local tests pass (if applicable)
- [ ] Code follows project style guidelines
- [ ] Commit message is clear and descriptive
- [ ] Only related changes included

## Output Format
```
## GitHub Actions Fix - Iteration N

### Current Status
Branch: [branch-name]
PR: #[number] - [title]
Failed Checks: [count]

### Failure Analysis
[Detailed analysis of what failed and why]

### Fixes Applied
1. [File]: [Change description]
2. [File]: [Change description]

### Local Verification
[Commands run and results]

### Commit & Push
SHA: [commit-hash]
Message: [commit-message]

### Action Status
[Link to running action]
Status: [Running/Passed/Failed]

{{ if failed }}
### Next Iteration Needed
Waiting for action to complete...
Run again to continue fixing.
{{ endif }}
```

## Example Scenarios

### Scenario 1: Elixir Test Failure
```
Error: mix test failed
Fix: Updated test assertion in test/accounts_test.exs
Verify: mix test passed locally
Result: Pushed fix, waiting for CI
```

### Scenario 2: Format Check Failure  
```
Error: mix format --check-formatted failed
Fix: Ran mix format on all files
Verify: mix format --check-formatted passed
Result: Pushed formatted code
```

### Scenario 3: Dependency Issue
```
Error: Could not compile dependency :phoenix
Fix: Updated phoenix version in mix.exs
Verify: mix deps.get && mix compile succeeded
Result: Pushed dependency update
```

## Completion Criteria

Continue iterations until:
```
✅ All GitHub Actions checks pass
✅ PR is green and ready for review
✅ No pending or failing workflows
```

Total iterations: {{ iteration_count | default: "1" }}/{{ max_iterations | default: "5" }}

