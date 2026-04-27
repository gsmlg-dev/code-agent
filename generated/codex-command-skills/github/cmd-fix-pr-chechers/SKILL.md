---
name: "cmd-fix-pr-chechers"
description: "Fix failing GitHub Actions in current PR"
---

# /fix-pr-chechers

Agent skill wrapper for the Claude command `/fix-pr-chechers`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Determine the current PR number and failing action name. Create a git worktree at `.trees/pr-<number>-<action>` for the PR branch (e.g. `.trees/pr-42-build`).

Inspect failing GitHub Actions logs using `gh run list` and `gh run view --log-failed`.

For each failure:
1. Analyze error context and stack traces
2. Fix the underlying issue in the worktree
3. Commit with message referencing the failure
4. Push to remote branch
5. Poll status with `gh run watch` (timeout 5 minutes)

If actions still fail, retrieve new logs and repeat (max 5 iterations total).

After 5 failed attempts, summarize remaining issues and exit.

Clean up the worktree on exit.

Run autonomously without approval checkpoints.
