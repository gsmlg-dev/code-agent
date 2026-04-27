---
name: "cmd-speckit-constitution"
description: "Define or update the project governing principles in .specify/memory/constitution.md"
---

# /speckit.constitution

Agent skill wrapper for the Claude command `/speckit.constitution`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Establish or update the project constitution — the single source of truth for governing principles that all specs and implementations must follow.

## Steps

1. **Locate the constitution**:
   - Check for `.specify/memory/constitution.md`.
   - If it does not exist and `.specify/` is absent, tell the user to run `/speckit.init` first and stop.
   - If the file exists, load its current content and note the current version.

2. **Identify placeholders and gaps**: Scan for:
   - Bracketed tokens: `[PROJECT_NAME]`, `[YYYY-MM-DD]`, `[Describe the project...]`
   - Non-declarative or untestable principles
   - Missing sections (MUST, SHOULD, SHOULD NOT are required at minimum)

3. **Collect values**:
   - `PROJECT_NAME`: Detect from `git remote get-url origin` (extract repo name), `package.json`, `mix.exs`, or ask the user.
   - Date: Today's date in ISO format (YYYY-MM-DD).
   - Project context: Ask the user — "Briefly describe this project's purpose, primary users, and key constraints."

4. **Present the proposed constitution** (full text for new files, or a diff for updates). Ask for confirmation before writing.

5. **Write the updated constitution**: Replace all placeholder tokens. Ensure:
   - Principles are declarative and testable ("All features..." not "We try to...")
   - Dates use ISO format (YYYY-MM-DD)
   - MUST = non-negotiable; SHOULD = strong default; SHOULD NOT = strong prohibition
   - No trailing whitespace or unresolved bracketed tokens

6. **Version bump** (updates to existing constitutions only):
   - MAJOR: removing or fundamentally changing a MUST principle
   - MINOR: adding new principles
   - PATCH: clarifying wording without changing intent

7. **Report**: File written, version, and a suggested commit message (e.g., `docs: ratify project constitution v0.1.0`).

**Next step**: Run `/speckit.specify` to write your first feature specification.
