---
description: Resolve ambiguities in spec.md through targeted Q&A before planning
argument-hint: [feature-name or path to spec.md]
---

Systematically resolve underspecified areas in a feature spec through structured questioning. Run before `/speckit.plan`.

## Steps

1. **Locate the spec**:
   - If input names a feature or file path, use it.
   - Otherwise check `.specify/specs/*/spec.md`; if multiple, ask which to clarify.
   - Fall back to `spec.md` in the project root.

2. **Load context**: Read `spec.md` and `.specify/memory/constitution.md` if present.

3. **Scan for ambiguities** across nine taxonomy categories:
   - Functional scope, Data model, UX flows, Non-functional attributes, Integration points, Edge cases, Constraints, Terminology, Completion signals.

4. **Select questions**: Choose the 5 highest-impact ambiguities. Prioritize by: scope > security > UX > technical detail. Each question must materially affect architecture, data modeling, testing, UX, or compliance.

5. **Ask one question at a time**:
   - Present the question with 2-5 multiple-choice options (or note that a short phrase is acceptable).
   - Mark the recommended answer with reasoning.
   - Wait for the user's answer before asking the next question.

6. **Update spec incrementally**: After each answer, incorporate the clarification naturally into the relevant spec section. Do not append a Q&A log — merge it into the prose.

7. **Final validation**: Check for duplicates, contradictions, and terminology drift across the updated spec.

8. **Report**: Coverage map across all nine ambiguity categories (resolved / deferred / clear / outstanding).

**Next step**: Run `/speckit.plan` to generate the technical implementation plan.

{{INPUT}}
