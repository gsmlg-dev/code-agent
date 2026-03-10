---
description: Fix failing GitHub Actions in current PR
agent: build
context: Run in isolated worktree if multiple fixes needed
---
Inspect the current branch's failing GitHub Actions logs to identify root cause.

For each failure:
1. Analyze error context and stack traces
2. Fix the underlying issue in code
3. Commit with descriptive message referencing the failure
4. Push to remote branch

After push, poll GitHub Actions status (max 5 minutes) using gh CLI.

If actions fail:
- Retrieve new failure logs
- Repeat fix cycle (max 3 iterations)
- If still failing after 3 iterations, summarize remaining issues and exit

Exit when all actions pass or iteration limit reached.

Run autonomously without approval checkpoints.

