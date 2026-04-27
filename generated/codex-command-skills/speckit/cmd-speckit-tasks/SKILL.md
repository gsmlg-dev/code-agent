---
name: "cmd-speckit-tasks"
description: "Generate a phase-based task breakdown in tasks.md from spec.md and plan.md"
---

# /speckit.tasks

Agent skill wrapper for the Claude command `/speckit.tasks`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Generate a dependency-ordered `tasks.md` with phase-based tasks derived from the feature specification and plan.

## Steps

1. **Locate artifacts**:
   - If input names a feature or directory, use it.
   - Otherwise check `.specify/specs/` and ask if multiple features exist.
   - Load: `spec.md` (user stories + priorities), `plan.md` (tech stack, phases). Optionally: `data-model.md`, `contracts/`, `research.md`.
   - Load `.specify/memory/constitution.md`.
   - Set `FEATURE_DIR` to the feature directory.

2. **Extract user stories and priorities**: From `spec.md`, extract each user story. Assign priority:
   - P1 = critical path (required for MVP)
   - P2 = important (needed for completion)
   - P3 = nice-to-have (can defer)

3. **Generate `FEATURE_DIR/tasks.md`**:

   ```markdown
   # Tasks: <Feature Name>

   ## Phase 1: Setup
   Shared infrastructure and scaffolding required by all subsequent phases.
   - [ ] [T001] [P] <task description> — <file path if applicable>
   - [ ] [T002] <task description>

   ## Phase 2: Foundation
   Blocking prerequisites that multiple user stories depend on.
   - [ ] [T010] [P] <task description>

   ## Phase 3: <User Story 1 Name> [US1]
   Implement [US1]: "As a [role], I want to [action]..."
   - [ ] [T020] [P] [US1] Write unit tests for <component>
   - [ ] [T021] [US1] Implement <component> core logic

   ## Phase N: Polish & Cross-Cutting Concerns
   - [ ] [TN00] [P] Add error handling across all endpoints
   - [ ] [TN01] Write integration tests for full workflow
   - [ ] [TN02] Update documentation
   ```

   Task format rules:
   - `[P]` marks a task as parallelizable (no blocking dependencies within the phase)
   - `[USn]` traces the task to user story n (Phase 3+ only)
   - Task IDs increment sequentially (T001, T002, ...)
   - Include file paths in task description when the task targets a specific file

4. **Report**: Task counts by phase, total parallelizable task count, which phases constitute the MVP scope.

**Next step**: Run `/speckit.checklist` to validate spec quality, or `/speckit.implement` to begin implementation.

{{INPUT}}
