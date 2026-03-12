---
description: Update chrome-devtools plugin skills from ChromeDevTools/chrome-devtools-mcp
---

Sync chrome-devtools plugin skills from upstream source https://github.com/ChromeDevTools/chrome-devtools-mcp

The upstream `skills/chrome-devtools` maps to our local `plugins/chrome-devtools/skills/chrome-devtools-mcp`.
All other upstream skill directories are copied directly.

## Steps

### 1. Clone the upstream repo

```bash
UPSTREAM_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/ChromeDevTools/chrome-devtools-mcp.git "$UPSTREAM_DIR"
```

### 2. Sync non-chrome-devtools skills

Copy all skill directories from upstream **except** `chrome-devtools`, replacing local versions:

```bash
PLUGIN_DIR="$(git rev-parse --show-toplevel)/plugins/chrome-devtools"

for skill_dir in "$UPSTREAM_DIR/skills"/*/; do
  skill=$(basename "$skill_dir")
  if [ "$skill" != "chrome-devtools" ]; then
    rm -rf "$PLUGIN_DIR/skills/$skill"
    cp -r "$skill_dir" "$PLUGIN_DIR/skills/$skill"
    echo "Updated skill: $skill"
  fi
done
```

### 3. Merge chrome-devtools into chrome-devtools-mcp

The upstream `skills/chrome-devtools/SKILL.md` is the base skill; our `chrome-devtools-mcp/SKILL.md` is an extended version.

Read both files and compare their content:

- Local: `plugins/chrome-devtools/skills/chrome-devtools-mcp/SKILL.md`
- Upstream: `$UPSTREAM_DIR/skills/chrome-devtools/SKILL.md`

Identify any **sections, content blocks, or notable text** present in the upstream file that are **not already present** in the local file. This includes new sections, updated descriptions, added notes, or new workflow patterns.

If new content is found, append it to the local `chrome-devtools-mcp/SKILL.md` under a comment like `<!-- synced from upstream -->` to mark the addition.

If there is nothing new in the upstream file, skip this step and note that `chrome-devtools-mcp` is already up to date.

### 4. Clean up

```bash
rm -rf "$UPSTREAM_DIR"
```

### 5. Report changes

Run `git diff --stat plugins/chrome-devtools/` to show what changed.

If there are changes, stage and commit:

```
git add plugins/chrome-devtools/
git commit -m "chore(chrome-devtools): sync from ChromeDevTools/chrome-devtools-mcp"
```

If no changes, report that the plugin is already up to date.

{{INPUT}}
