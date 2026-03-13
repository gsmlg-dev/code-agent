---
description: Fix all open GitHub issues labeled `internal request` in isolated worktrees, then open PRs
agent: debugger
context: Each issue gets its own worktree; never modifies the main working directory
---
# Fix Internal Request Issues

Fix all open GitHub issues labeled `internal request` in isolated worktrees, then open PRs.

## Setup (once)
```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
REPO_ROOT=$(git rev-parse --show-toplevel)
BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
mkdir -p .trees
gh label create "internal request fixed" --color "0e8a16" --force 2>/dev/null
gh label create "unable to resolve" --color "e4e669" --force 2>/dev/null
```

## 1. List Issues

Fetch open issues labeled `internal request` via GitHub MCP using `$REPO`. Post-fetch, exclude any with `unable to resolve` label or that already have an open PR targeting `fix/issue-{number}`.

If none remain, report "No open internal request issues" and stop.

Print summary table: number, title, labels.

## 2. Per-Issue Loop

For each issue, sequentially:

### Branch & Worktree
```bash
git worktree remove .trees/issue-{number} 2>/dev/null; git branch -D fix/issue-{number} 2>/dev/null
git worktree add .trees/issue-{number} -b fix/issue-{number} "$BASE_BRANCH"
```

### Fix
Work **only** inside `.trees/issue-{number}/`:
1. Read the issue body — identify affected files, expected behavior, repro steps
2. Implement minimum viable fix (add tests if warranted)
3. Verify the fix builds and tests pass

### Commit & PR
```bash
cd .trees/issue-{number}
git add -A && git commit -m "fix: {description} (fixes #{number})"
git push -u origin fix/issue-{number}
gh pr create --base "$BASE_BRANCH" --head fix/issue-{number} \
  --title "fix: {description}" \
  --label "internal request fixed" \
  --body $'## Summary\n- {bullets}\n\nFixes #{number}'
```

### Cleanup
```bash
cd "$REPO_ROOT"
git worktree remove .trees/issue-{number}
```

### On Failure
If the issue can't be fixed (ambiguous scope, missing info, design decisions needed):
1. `gh issue edit {number} --add-label "unable to resolve"`
2. `gh issue comment {number} --body "Automated fix not possible: {reason}"`
3. Clean up worktree/branch, mark as skipped

## 3. Summary
```
Repo: $REPO
Internal Request Issues Processed:
  #{n} — {title} → PR #{pr} (fix/issue-{n})
  #{m} — {title} → Skipped: {reason}

Created: X | Skipped: Y | Failed: Z
```

## Constraints
- Never modify main working directory — worktrees only
- Never push code that fails build or tests
- Use `fixes #{number}` in commit message for auto-close on merge
- Build/test commands are repo-specific — read from project config or CLAUDE.md
