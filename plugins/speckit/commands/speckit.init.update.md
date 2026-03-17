---
description: Update .specify/ scripts and templates from upstream github/spec-kit
---

Refresh the `.specify/` scripts and templates in the current project by downloading the latest versions from `github/spec-kit`. Never overwrites user-governed files.

## Protected paths (never overwrite)
- `.specify/memory/` — all files including `constitution.md`
- `.specify/specs/` — all feature artifacts

## Steps

1. **Verify setup**: Check that `.specify/` exists in the project root. If not, stop and tell the user to run `/speckit.init` first.

2. **Clone upstream**:
   ```bash
   UPSTREAM_DIR=$(mktemp -d)
   git clone --depth 1 https://github.com/github/spec-kit.git "$UPSTREAM_DIR"
   ```
   If the clone fails, report the error and stop.

3. **Update files** by copying from upstream, skipping protected paths. For each file in the upstream `.specify/` directory:

   | Upstream source | Local destination | Protected? |
   |----------------|-------------------|------------|
   | `.specify/memory/constitution.md` | `.specify/memory/constitution.md` | YES — skip |
   | `.specify/scripts/bash/common.sh` | `.specify/scripts/bash/common.sh` | update |
   | `.specify/scripts/bash/setup-plan.sh` | `.specify/scripts/bash/setup-plan.sh` | update |
   | `.specify/scripts/bash/check-prerequisites.sh` | `.specify/scripts/bash/check-prerequisites.sh` | update |
   | `.specify/scripts/bash/update-agent-context.sh` | `.specify/scripts/bash/update-agent-context.sh` | update |
   | `.specify/scripts/bash/create-new-feature.sh` | `.specify/scripts/bash/create-new-feature.sh` | update |
   | `.specify/templates/agent-file-template.md` | `.specify/templates/agent-file-template.md` | update |
   | `.specify/templates/checklist-template.md` | `.specify/templates/checklist-template.md` | update |
   | `.specify/templates/tasks-template.md` | `.specify/templates/tasks-template.md` | update |
   | `.specify/templates/spec-template.md` | `.specify/templates/spec-template.md` | update |
   | `.specify/templates/plan-template.md` | `.specify/templates/plan-template.md` | update |

   Also copy any additional `.specify/scripts/` or `.specify/templates/` files found in upstream that are not listed above (new upstream additions). Preserve file permissions.

4. **Clean up**:
   ```bash
   rm -rf "$UPSTREAM_DIR"
   ```

5. **Report** a summary table:
   ```
   Status   | File                                        | Reason
   UPDATED  | .specify/templates/spec-template.md         | Content changed
   ADDED    | .specify/scripts/bash/new-script.sh         | New upstream file
   SKIPPED  | .specify/memory/constitution.md             | User-governed
   SKIPPED  | .specify/specs/                             | User-governed
   ```

6. **Next step**: Review any updated templates before running `/speckit.specify` or `/speckit.plan` in case template changes affect expected output format.
