---
name: "cmd-speckit-implement"
description: "Execute implementation phase-by-phase following tasks.md"
---

# /speckit.implement

Agent skill wrapper for the Claude command `/speckit.implement`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Execute the implementation plan for a feature by working through `tasks.md` phase by phase, using TDD where applicable.

## Steps

1. **Locate artifacts**:
   - If input names a feature, directory, or phase number, parse it.
   - Load required: `tasks.md`, `plan.md`. Load optional: `data-model.md`, `contracts/`, `research.md`.
   - Load `.specify/memory/constitution.md`.
   - Set `FEATURE_DIR` to the feature directory.

2. **Check checklists**: Scan `FEATURE_DIR/checklists/` for any uncompleted items (`- [ ]`). If found, report them and ask: "There are incomplete checklist items. Proceed anyway?" Stop if the user declines.

3. **Determine starting phase**:
   - If a phase number was provided in input, start there.
   - Otherwise start from Phase 1.
   - Skip phases where all tasks are already marked `[x]`.

4. **Execute each phase**:
   - Announce the phase name and task count before starting.
   - For tasks marked `[P]` (parallelizable): execute them concurrently.
   - For tasks without `[P]`: execute in listed order.
   - For each task:
     - Write tests first (TDD), then implement the minimum code to satisfy the task.
     - Mark the task `[x]` in `tasks.md` immediately after completion.
     - Run available test and lint commands to verify no regressions.
   - If a non-parallelizable task fails, stop and report. Do not proceed to the next task until resolved.

5. **Validate completion** after all phases:
   - All tasks in `tasks.md` are marked `[x]`.
   - All functional requirements from `spec.md` are addressed.
   - Tests pass and no new lint errors.

6. **Report**: Tasks completed, any skipped tasks with reasons, test results summary.

**Next step**: Run `/speckit.taskstoissues` to track remaining work as GitHub issues, or commit and open a PR.

{{INPUT}}
