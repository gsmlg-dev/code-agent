---
description: Update speckit plugin commands from github/spec-kit
---

Sync speckit plugin commands from upstream source https://github.com/github/spec-kit

The upstream `templates/commands/` directory maps to our local `plugins/speckit/commands/`, with filenames prefixed as `speckit.<name>.md`.

Our locally-added commands (`speckit.init.md` and `speckit.init.update.md`) are never overwritten.

## Steps

### 1. Clone the upstream repo

```bash
UPSTREAM_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/github/spec-kit.git "$UPSTREAM_DIR"
```

### 2. Sync upstream command templates

For each `.md` file in `$UPSTREAM_DIR/templates/commands/`, copy it to `plugins/speckit/commands/speckit.<name>.md`, replacing the existing local version.

```bash
PLUGIN_DIR="$(git rev-parse --show-toplevel)/plugins/speckit"

for cmd_file in "$UPSTREAM_DIR/templates/commands"/*.md; do
  name=$(basename "$cmd_file" .md)
  cp "$cmd_file" "$PLUGIN_DIR/commands/speckit.$name.md"
  echo "Updated command: speckit.$name"
done
```

### 3. Preserve locally-added commands

Ensure these files are NOT overwritten (they have no upstream equivalent):

- `plugins/speckit/commands/speckit.init.md`
- `plugins/speckit/commands/speckit.init.update.md`

If the previous step accidentally replaced them, restore them from git:

```bash
git checkout -- plugins/speckit/commands/speckit.init.md
git checkout -- plugins/speckit/commands/speckit.init.update.md
```

### 4. Review upstream command content

The upstream commands reference shell scripts (`scripts/bash/*.sh`) which don't apply in the Claude Code plugin context. For any updated command file, check whether the content is still instruction-based (not shell-script-centric). If an upstream command has regressed to only containing shell script invocations without Claude-readable steps, note it in the report and keep the previous local version.

### 5. Clean up

```bash
rm -rf "$UPSTREAM_DIR"
```

### 6. Report changes

Run `git diff --stat plugins/speckit/` to show what changed.

If there are changes, stage and commit:

```
git add plugins/speckit/
git commit -m "chore(speckit): sync commands from github/spec-kit"
```

If no changes, report that the plugin is already up to date.

{{INPUT}}
