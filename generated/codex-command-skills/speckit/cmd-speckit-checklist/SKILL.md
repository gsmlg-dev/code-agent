---
name: "cmd-speckit-checklist"
description: "Create domain-specific quality checklists validating spec completeness and clarity"
---

# /speckit.checklist

Agent skill wrapper for the Claude command `/speckit.checklist`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Generate requirements quality checklists — "unit tests for requirements writing." These validate that specs are complete, clear, and unambiguous. They do NOT test implementation behavior.

## Steps

1. **Parse input**: From the provided input, identify a quality domain (e.g., `security`, `performance`, `API design`, `data modeling`) and/or a feature name. If neither is clear, ask up to 3 targeted questions:
   - What feature is this checklist for?
   - What quality domain should it focus on?
   - Are there specific concerns from the constitution or prior analysis?

2. **Locate artifacts**: Load `spec.md` for the identified feature, plus `plan.md` and `tasks.md` if available. Load `.specify/memory/constitution.md`.

3. **Generate `FEATURE_DIR/checklists/<domain>.md`**:

   ```markdown
   # Quality Checklist: <Domain> — <Feature Name>

   **Generated**: <YYYY-MM-DD>
   **Scope**: Requirements quality validation (not implementation verification)

   ## Completeness
   - [ ] CHK001 Are all user scenarios covered by at least one functional requirement? [Completeness, Spec §User Scenarios]
   - [ ] CHK002 Does each functional requirement have a corresponding success criterion? [Completeness, Spec §Success Criteria]

   ## Clarity
   - [ ] CHK010 Are all vague terms replaced with measurable criteria? [Clarity, Gap]
   - [ ] CHK011 Is every acronym and domain term defined? [Clarity, Spec §Key Entities]

   ## Consistency
   - [ ] CHK020 Is the same term used consistently for the same concept throughout? [Consistency]

   ## Coverage
   - [ ] CHK030 Are error conditions addressed for each user scenario? [Gap]
   - [ ] CHK031 Are non-functional requirements specified? [Gap]

   ## Measurability
   - [ ] CHK040 Does each success criterion include a specific metric or verifiable condition? [Measurability, Spec §Success Criteria]
   ```

   Item rules:
   - Ask about requirement quality, never implementation success. Bad: "Verify the button works." Good: "Is the expected button behavior described for each user scenario?"
   - Include a quality dimension in brackets: `[Completeness]`, `[Clarity]`, `[Consistency]`, `[Gap]`, `[Ambiguity]`, `[Conflict]`, `[Measurability]`
   - Reference specific spec sections: `[Spec §X.Y]`
   - At least 80% of items must trace to a specific spec section or an identified gap

4. **Report**: File path, total item count, breakdown by quality dimension.

**Next step**: Complete all checklist items before running `/speckit.implement`.

{{INPUT}}
