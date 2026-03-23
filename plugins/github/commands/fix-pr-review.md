---
description: Fix review comments on current PR
allowed-tools: bash, mcp__github
---

Determine the current PR number. Create a git worktree at `.trees/pr-<number>-review` for the PR branch.

Fetch pending review comments using `gh pr view` and `gh api` for review threads.

For each unresolved comment:
1. Read the comment context and referenced code
2. Apply the requested change in the worktree
3. Commit with message referencing the review comment
4. Resolve the thread if possible via `gh api`

After all comments are addressed, spawn 3 parallel review subagents on the full diff:
1. Code quality reviewer — correctness, patterns, regressions
2. Business logic reviewer — requirements alignment, edge cases
3. Security reviewer — vulnerabilities, input validation

Aggregate findings. If any reviewer flags issues:
1. Fix flagged issues in the worktree
2. Re-run the review team (max 3 iterations)

Push all changes to the remote branch once all reviewers pass.

Clean up the worktree on exit.

Run autonomously without approval checkpoints.