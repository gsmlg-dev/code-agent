---
name: "cmd-speckit-taskstoissues"
description: "Convert tasks.md into GitHub issues in the current repository"
---

# /speckit.taskstoissues

Agent skill wrapper for the Claude command `/speckit.taskstoissues`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Create GitHub issues from the tasks in `tasks.md`, in dependency order. Skips already-completed tasks.

## Safety rules (enforce strictly)
- Never create issues in a repository that does not match the current `git remote origin`.
- Confirm `owner/repo` with the user before creating any issues.
- Skip completed tasks (marked `[x]`) silently and note the count.
- Escape special characters in issue titles and bodies.

## Steps

1. **Locate tasks.md**:
   - If input names a feature or file path, use it.
   - Otherwise check `.specify/specs/*/tasks.md`; if multiple, ask which.
   - Fall back to `tasks.md` in the project root.

2. **Validate GitHub remote**: Run `git config --get remote.origin.url`. Verify it returns a `github.com` URL. If not, stop: "This command requires a GitHub remote. The current remote is not a GitHub URL."

3. **Identify the repository**: Parse the remote URL to extract `owner/repo`. Display it and ask the user to confirm before creating any issues.

4. **Parse tasks**: Extract all tasks from `tasks.md`, preserving:
   - Phase name and number
   - Task ID (T001, T002, ...)
   - Parallelizable flag (`[P]`)
   - User story reference (`[USn]`)
   - Task description and any file paths

5. **Create issues** for each incomplete task (not marked `[x]`), in phase and ID order:
   - **Title**: `[Phase N] [T0XX] <task description>`
   - **Body**: Phase name, user story reference (if present), link to the feature spec file, task description.
   - **Labels**: Create a `speckit` label (color `#6366f1`) if absent. Add `phase-N` label. Add `parallelizable` label if `[P]`.

6. **Report** a summary table:
   ```
   Task ID | Issue # | Title                                   | Labels
   T001    | #42     | [Phase 1] [T001] Create database models | speckit, phase-1, parallelizable
   T003    | SKIPPED | Already completed                       | —
   ```

{{INPUT}}
