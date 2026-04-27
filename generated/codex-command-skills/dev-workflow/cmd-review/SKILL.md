---
name: "cmd-review"
description: "Code review using the reviewer agent"
---

# /review

Agent skill wrapper for the Claude command `/review`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Perform a thorough code review following your workflow, checklist, and feedback framework.

{{INPUT}}
