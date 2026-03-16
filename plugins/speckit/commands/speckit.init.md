---
description: Initialize the .specify/ directory structure for Spec-Driven Development in the current project
---

Set up the `.specify/` directory structure for Specification-Driven Development in the current project.

## Steps

1. **Check for existing setup**: Look for `.specify/` in the project root. If it already exists, stop and tell the user to run `/speckit.init.update` instead.

2. **Detect project name**: Try in order — `git remote get-url origin` (extract repo name from URL), `package.json` `name` field, `mix.exs` app name, directory basename. Use this as `PROJECT_NAME`.

3. **Create directories**:
   - `.specify/memory/` — project memory and governing principles
   - `.specify/specs/` — feature specification artifacts (one subdirectory per feature)

4. **Create `.specify/memory/constitution.md`** with this starter template (replace tokens):
   ```markdown
   # Project Constitution

   **Project**: PROJECT_NAME
   **Ratified**: YYYY-MM-DD
   **Version**: 0.1.0

   ## Governing Principles

   ### MUST
   - All features begin with a written spec before implementation
   - Specifications focus on WHAT and WHY, not HOW
   - Success criteria must be measurable and user-focused
   - Resolve all [NEEDS CLARIFICATION] markers before planning begins

   ### SHOULD
   - Keep specifications technology-agnostic where possible
   - Document architectural decisions and their rationale
   - Run `/speckit.analyze` before `/speckit.implement`

   ### SHOULD NOT
   - Include implementation details in feature specifications
   - Skip the clarify phase when requirements are ambiguous

   ## Project Context

   [Describe the project purpose, primary users, and key constraints here.]
   ```

5. **Update `.gitignore`**: Only if `.gitignore` exists and does not already contain `.specify/`. Append `.specify/` as a new line. If no `.gitignore` exists, skip and note it.

6. **Report** all directories and files created.

7. **Present the SDD workflow overview**:
   ```
   Spec-Driven Development workflow:
     /speckit.constitution  → Define governing principles (run once per project)
     /speckit.specify       → Write a feature spec
     /speckit.clarify       → Resolve ambiguities in the spec
     /speckit.plan          → Generate technical plan + data model + contracts
     /speckit.analyze       → Validate consistency across artifacts (read-only)
     /speckit.tasks         → Generate phase-based task breakdown
     /speckit.checklist     → Create quality checklists for the spec
     /speckit.implement     → Execute implementation phase by phase
     /speckit.taskstoissues → Convert tasks into GitHub issues
   ```

8. **Next step**: "Run `/speckit.constitution` to complete your project constitution with project-specific principles, then `/speckit.specify` to write your first feature spec."
