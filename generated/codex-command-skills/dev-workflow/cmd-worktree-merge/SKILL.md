---
name: "cmd-worktree-merge"
description: "Merge all worktrees from .trees/ into current branch and clean up"
---

# /worktree-merge

Agent skill wrapper for the Claude command `/worktree-merge`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Merge all git worktrees under the `.trees/` directory into the current branch.

## Steps

1. Run `git worktree list` to identify worktrees in `.trees/`.
2. For each worktree (in alphabetical order):
   a. Get its branch name from `git worktree list`.
   b. Run `git merge <branch> --no-edit`.
   c. If conflicts arise, analyze and resolve them, preferring to combine both sides when possible.
   d. After successful merge, run `git worktree remove <path>` and `git branch -d <branch>`.
3. Verify final state with `git status` and `git log --oneline -n 10`.

{{INPUT}}
