---
name: "cmd-speckit-init"
description: "Initialize the .specify/ directory structure for Spec-Driven Development in the current project"
---

# /speckit.init

Agent skill wrapper for the Claude command `/speckit.init`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Set up the `.specify/` directory structure for Specification-Driven Development in the current project by downloading the latest files from the upstream `github/spec-kit` repository.

## Steps

1. **Check for existing setup**: Look for `.specify/` in the project root. If it already exists, stop and tell the user to run `/speckit.init.update` instead.

2. **Clone upstream**:
   ```bash
   UPSTREAM_DIR=$(mktemp -d)
   git clone --depth 1 https://github.com/github/spec-kit.git "$UPSTREAM_DIR"
   ```
   If the clone fails, report the error and stop.

3. **Copy files from upstream** into the project root, preserving the paths exactly:

   | Upstream source | Local destination |
   |----------------|-------------------|
   | `.specify/memory/constitution.md` | `.specify/memory/constitution.md` |
   | `.specify/scripts/bash/common.sh` | `.specify/scripts/bash/common.sh` |
   | `.specify/scripts/bash/setup-plan.sh` | `.specify/scripts/bash/setup-plan.sh` |
   | `.specify/scripts/bash/check-prerequisites.sh` | `.specify/scripts/bash/check-prerequisites.sh` |
   | `.specify/scripts/bash/update-agent-context.sh` | `.specify/scripts/bash/update-agent-context.sh` |
   | `.specify/scripts/bash/create-new-feature.sh` | `.specify/scripts/bash/create-new-feature.sh` |
   | `.specify/templates/agent-file-template.md` | `.specify/templates/agent-file-template.md` |
   | `.specify/templates/checklist-template.md` | `.specify/templates/checklist-template.md` |
   | `.specify/templates/tasks-template.md` | `.specify/templates/tasks-template.md` |
   | `.specify/templates/spec-template.md` | `.specify/templates/spec-template.md` |
   | `.specify/templates/plan-template.md` | `.specify/templates/plan-template.md` |

   Create any intermediate directories as needed. Preserve file permissions (especially executable bits on shell scripts).

4. **Clean up**:
   ```bash
   rm -rf "$UPSTREAM_DIR"
   ```

5. **Detect project name**: Try in order — `git remote get-url origin` (extract repo name from URL), `package.json` `name` field, `mix.exs` app name, directory basename. Use this as `PROJECT_NAME`.

6. **Personalize `.specify/memory/constitution.md`**: Replace placeholder tokens in the downloaded file:
   - `[PROJECT_NAME]` → detected project name
   - `[YYYY-MM-DD]` → today's date in ISO format

7. **Create `.specify/specs/`**: Make this directory for feature specification artifacts (one subdirectory per feature). This directory is not present in upstream.

8. **Update `.gitignore`**: Only if `.gitignore` exists and does not already contain `.specify/`. Append `.specify/` as a new line. If no `.gitignore` exists, skip and note it.

9. **Report** all directories and files created with their paths.

10. **Present the SDD workflow overview**:
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

11. **Next step**: "Run `/speckit.constitution` to complete your project constitution with project-specific principles, then `/speckit.specify` to write your first feature spec."
