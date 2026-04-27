---
name: "cmd-speckit-analyze"
description: "Validate cross-artifact consistency across spec.md, plan.md, and tasks.md (read-only)"
---

# /speckit.analyze

Agent skill wrapper for the Claude command `/speckit.analyze`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Read-only consistency check across all specification artifacts for a feature. No files are modified.

## Steps

1. **Locate artifacts**:
   - If input names a feature or directory, use it.
   - Otherwise check `.specify/specs/` and ask if multiple features exist.
   - Load all available: `spec.md`, `plan.md`, `tasks.md`, `data-model.md`, `contracts/*.md`, `research.md`.
   - Load `.specify/memory/constitution.md`.

2. **Run six consistency checks**. Record each finding with: category, severity (CRITICAL / HIGH / MEDIUM / LOW), location, description.

   - **Constitution conflicts** (auto-CRITICAL): Any plan or task that violates a MUST or SHOULD NOT principle.
   - **Coverage gaps**: Requirements with no corresponding tasks; tasks traceable to no requirement.
   - **Inconsistency**: Terminology drift, conflicting tech choices, ordering contradictions between artifacts.
   - **Ambiguity**: Vague terms (`fast`, `scalable`, `secure`) without measurable criteria; unresolved `[NEEDS CLARIFICATION]` markers.
   - **Underspecification**: Incomplete acceptance criteria, undefined component references, missing error conditions in contracts.
   - **Duplication**: Near-identical requirements or tasks appearing in multiple places.

3. **Produce analysis report** in the conversation (do not write to any file):

   ```
   ## Consistency Analysis: <Feature Name>

   ### Findings (sorted CRITICAL → HIGH → MEDIUM → LOW, max 50 rows)
   | # | Severity | Category | Location | Finding |

   ### Coverage Matrix
   Each spec.md requirement → mapped tasks (or NONE)
   Each tasks.md task → source requirement (or NONE)

   ### Metrics
   - Requirement coverage: X%
   - Constitution violations: N
   - Ambiguous items: N
   - Duplicate items: N

   ### Recommended Next Actions
   ```

4. **Offer remediation**: If findings exist, ask: "Would you like me to fix any of these?" Apply only user-approved edits.

**Next step**: Address any CRITICAL findings, then run `/speckit.tasks`.

{{INPUT}}
