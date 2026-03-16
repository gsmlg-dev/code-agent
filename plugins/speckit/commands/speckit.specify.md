---
description: Transform a feature description into a structured spec.md
argument-hint: <feature description>
---

Create a structured feature specification from the description. Focus strictly on WHAT and WHY — never HOW.

## Steps

1. **Validate input**: If no description was provided, ask: "What feature would you like to specify?" and wait for the response.

2. **Determine feature location**:
   - If `.specify/specs/` exists: derive a 2-4 word kebab-case name from the description (action-noun format, e.g. `oauth-api-integration`). Write to `.specify/specs/<feature-name>/spec.md`.
   - If `.specify/` does not exist: write to `spec.md` in the project root and remind the user that `/speckit.init` has not been run.

3. **Load context**: If `.specify/memory/constitution.md` exists, read it for governing principles and project constraints.

4. **Write the spec** to the determined path. Omit any section that does not apply:

   ```markdown
   # Feature Specification: <Feature Name>

   **Status**: Draft
   **Created**: <YYYY-MM-DD>

   ## Overview
   One paragraph: what this feature is and why it exists. Written for business stakeholders.

   ## User Scenarios
   1. As a [role], I want to [action] so that [outcome].

   ## Functional Requirements
   Numbered list. Each requirement must be testable, technology-agnostic, and behavior-focused.

   ## Success Criteria
   Measurable outcomes with specific metrics or verifiable conditions.

   ## Key Entities
   (Include only if the feature involves persistent data)
   Name and description of core domain objects.

   ## Out of Scope
   Explicit list of what this feature does NOT include.

   ## Open Questions
   <!-- [NEEDS CLARIFICATION] items — max 3 -->
   ```

5. **Self-validate**: Check — no implementation details, measurable success criteria, at most 3 `[NEEDS CLARIFICATION]` markers, scope is bounded.

6. **Resolve open questions interactively**: Present each `[NEEDS CLARIFICATION]` item as a multiple-choice question (2-5 options, recommended answer marked). Update the spec based on user selections.

7. **Report**: State the file path and confirm readiness for the next step.

**Next step**: Run `/speckit.clarify` if ambiguities remain, or `/speckit.plan` when the spec is complete.

{{INPUT}}
