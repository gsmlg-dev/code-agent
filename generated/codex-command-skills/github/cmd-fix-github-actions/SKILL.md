---
name: "cmd-fix-github-actions"
description: "Fix GitHub Actions failures by analyzing recent workflow runs and applying fixes in a worktree"
---

# /fix-github-actions

Agent skill wrapper for the Claude command `/fix-github-actions`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Fix GitHub Actions failures from recent workflow runs. Work in a git worktree under `.trees/`. Repeat up to $1 times (default 5).

## Process

1. **Identify failures**: `gh run list --status=failure --limit=5` then `gh run view <run-id> --log-failed` for details
2. **Create worktree**: Branch from the failing ref into `.trees/fix-ci-<short-description>` — create `.trees/` if missing
3. **Analyze and fix**: Categorize failure (test/build/lint/deps/other), fix root cause in the worktree
4. **Verify locally** when possible (e.g. `mix test`, `mix format --check-formatted`, `mix compile`)
5. **Commit with descriptive message**, push the fix branch
6. **Re-check**: `gh run watch` — if still failing, continue next iteration

## Rules

- Fix root causes, not symptoms
- Do not skip/disable tests or modify CI workflow config without human approval
- Do not make unrelated changes
- Keep each commit focused on the specific failure being fixed

## Stop and ask for human review if

- Same failure recurs 3+ times despite different fix approaches
- Failure is caused by secrets, credentials, or external infrastructure
- Fix requires significant architectural changes
- CI workflow YAML itself needs modification
