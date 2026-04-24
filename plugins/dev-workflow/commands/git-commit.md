---
description: Stage and commit changes with conventional commit message
---
Analyze staged/unstaged changes to determine logical scope and type.

Generate conventional commit message:
- Format: <type>(<scope>): <description>
- Types: feat|fix|docs|style|refactor|test|chore
- Keep subject under 72 chars
- Add body if context from {{INPUT}} requires explanation

If changes span multiple scopes, create separate commits per logical unit.

Stage files with `git add` and commit. Run autonomously without approval.

{{INPUT}}

