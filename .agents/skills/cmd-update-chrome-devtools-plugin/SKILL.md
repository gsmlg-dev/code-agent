---
name: cmd-update-chrome-devtools-plugin
disable-model-invocation: true
description: Update chrome-devtools plugin skills from ChromeDevTools/chrome-devtools-mcp
---

Sync chrome-devtools plugin skills from upstream source https://github.com/ChromeDevTools/chrome-devtools-mcp

The upstream `skills/chrome-devtools` maps to our local `plugins/chrome-devtools/skills/chrome-devtools-mcp`.
All other upstream skill directories are copied directly.

## Steps

### 0. Capture the update baseline

Before changing files, record the repository state and log path:

```bash
BASE_COMMIT=$(git rev-parse HEAD)
LOG_FILE="$(git rev-parse --show-toplevel)/.agents/skills/cmd-update-chrome-devtools-plugin/UPDATES.md"
```

After the clone and sync steps, and before cleanup, capture the upstream ref and file-level changes:

```bash
UPSTREAM_REF=$(git -C "$UPSTREAM_DIR" rev-parse HEAD)
git diff --name-status "$BASE_COMMIT" -- plugins/chrome-devtools/
```

Append a dated entry to `"$LOG_FILE"` with the source URL/ref, `BASE_COMMIT`, target, Added/Modified/Deleted counts, and each changed path. Include this restore command for deleted paths: `git restore --source <base-commit> -- plugins/chrome-devtools/<path>`. Stage the log together with plugin changes and commit them in the same commit.

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

### 5. Regenerate Codex and Cursor plugins

The `.codex-plugin/plugins/` and `.cursor-plugin/plugins/` trees are checked-in
distribution bundles and must be rebuilt from the updated source plugin. Run
both generators from the repository root:

```bash
node scripts/generate-codex-plugins
node scripts/generate-cursor-plugins
```

Do not edit generated files manually. Confirm the generated
`chrome-devtools` bundles include the same skills and reference files as
`plugins/chrome-devtools/`.

### 6. Validate and report changes

Run the repository validators before staging:

```bash
node scripts/validate
node scripts/validate-cursor
git diff --check
```

Run `git diff --stat plugins/chrome-devtools/` to show what changed.

Stage the source plugin, generated Codex/Cursor bundles, marketplace metadata,
and update log together. If there are changes, commit them with:

```
git add plugins/chrome-devtools/
git add .codex-plugin/plugins/chrome-devtools/ .cursor-plugin/plugins/chrome-devtools/
git add .claude-plugin/marketplace.json .agents/skills/cmd-update-chrome-devtools-plugin/UPDATES.md
git commit -m "chore(chrome-devtools): sync from ChromeDevTools/chrome-devtools-mcp"
```

If no changes, report that the plugin is already up to date.

{{INPUT}}
