---
description: Update spec-kit templates in an existing project from upstream github/spec-kit
---

Refresh spec-kit templates in the current project by fetching the latest versions from the upstream `github/spec-kit` repository. Never overwrites user-governed files.

## Protected files (never overwrite)
- `.specify/memory/` — all files (including `constitution.md`)
- `.specify/specs/` — all feature artifacts

## Steps

1. **Verify setup**: Check that `.specify/` exists in the project root. If not, stop and tell the user to run `/speckit.init` first.

2. **Shallow clone upstream**:
   ```bash
   git clone --depth 1 https://github.com/github/spec-kit.git /tmp/spec-kit-update-$$
   ```
   If the clone fails (no internet, git unavailable), report the error and stop.

3. **Identify available templates**: List all files under `/tmp/spec-kit-update-$$/templates/` recursively.

4. **Apply updates**:
   - For each template file: compare with the equivalent in `.specify/templates/` (create directory if needed).
   - Copy newer or new files into `.specify/templates/`.
   - Skip any file matching the protected paths above.
   - Track: files updated, files added, files skipped (with reason).

5. **Clean up**: `rm -rf /tmp/spec-kit-update-$$`

6. **Report** a summary table:
   ```
   Status   | File                          | Reason
   UPDATED  | templates/spec-template.md    | Content changed
   ADDED    | templates/quickstart.md       | New upstream file
   SKIPPED  | memory/constitution.md        | User-governed
   ```

7. **Next step**: Note any commands whose behavior may change due to template updates and suggest reviewing them.

## Notes
- Requires internet access and `git`.
- `.specify/memory/` and `.specify/specs/` are never touched.
