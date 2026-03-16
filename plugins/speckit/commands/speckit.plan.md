---
description: Generate technical plan, data model, and interface contracts from spec.md
argument-hint: [feature-name or path to spec.md]
---

Produce a complete technical implementation plan from a feature specification.

## Steps

1. **Locate the spec**:
   - If input names a feature or file path, use it.
   - Otherwise check `.specify/specs/*/spec.md`; if multiple, ask which to plan.
   - Fall back to `spec.md` in the project root.
   - Set `FEATURE_DIR` to the spec's parent directory.

2. **Load context**: Read `spec.md` and `.specify/memory/constitution.md`. Detect tech stack from `package.json`, `mix.exs`, `Cargo.toml`, `pyproject.toml`, `go.mod`, etc.

3. **Phase 0 — Research**: For each `[NEEDS CLARIFICATION]` marker and technical unknown:
   - Search the codebase for existing patterns and abstractions.
   - Identify required external dependencies.
   - Write findings to `FEATURE_DIR/research.md`:
     ```markdown
     # Research: <Feature Name>
     ## Unknowns Investigated
     ## Existing Patterns Found
     ## External Dependencies
     ```
   - Resolve all open questions before proceeding.

4. **Phase 1 — Design artifacts**:

   Write `FEATURE_DIR/plan.md`:
   ```markdown
   # Technical Plan: <Feature Name>
   ## Architecture Overview
   ## Technology Choices (with rationale)
   ## Component Design
   ## Implementation Phases
   ## Risk Assessment
   ## Open Technical Questions
   ```

   Write `FEATURE_DIR/data-model.md` (only if the feature involves persistent data):
   ```markdown
   # Data Model: <Feature Name>
   ## Entities (fields, types, constraints, relationships)
   ## Migrations (in dependency order)
   ## Indexes (with justification)
   ```

   Create `FEATURE_DIR/contracts/<interface-name>.md` for each external interface:
   ```markdown
   # Contract: <Interface Name>
   ## Signature / Endpoint
   ## Request / Input Schema
   ## Response / Output Schema
   ## Error Conditions
   ## Constraints
   ```

5. **Constitution check**: Verify the plan does not violate any MUST or SHOULD NOT principle. If violations found, flag `[CONSTITUTION CONFLICT]` and pause for user review before continuing.

6. **Report**: List all files created with paths and one-line summaries.

**Next step**: Run `/speckit.analyze` to validate consistency, or `/speckit.tasks` to generate the task breakdown.

{{INPUT}}
