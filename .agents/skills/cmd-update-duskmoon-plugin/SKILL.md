---
name: cmd-update-duskmoon-plugin
disable-model-invocation: true
description: Update duskmoon-ui plugin skills from upstream repos
---

Sync duskmoon-ui plugin skills from upstream sources:
- https://github.com/duskmoon-dev/duskmoonui
- https://github.com/duskmoon-dev/phoenix-duskmoon-ui
- https://github.com/duskmoon-dev/duskmoon-elements
- https://github.com/duskmoon-dev/duskmoon-react

## Steps

### 0. Capture the update baseline

Before changing files, record the repository state and log path:

```bash
BASE_COMMIT=$(git rev-parse HEAD)
LOG_FILE="$(git rev-parse --show-toplevel)/.agents/skills/cmd-update-duskmoon-plugin/UPDATES.md"
```

After the clone and sync steps, and before cleanup, capture each upstream ref and file-level changes:

```bash
UPSTREAM_REF="duskmoonui=$(git -C "$DUSKMOON_DIR" rev-parse HEAD); phoenix=$(git -C "$PHOENIX_DIR" rev-parse HEAD); elements=$(git -C "$ELEMENTS_DIR" rev-parse HEAD); react=$(git -C "$REACT_DIR" rev-parse HEAD)"
git diff --name-status "$BASE_COMMIT" -- plugins/duskmoon-ui/
```

Append a dated entry to `"$LOG_FILE"` with source URLs/refs, `BASE_COMMIT`, target, Added/Modified/Deleted counts, and each changed path. Include this restore command for deleted paths: `git restore --source <base-commit> -- plugins/duskmoon-ui/<path>`. Stage the log together with plugin changes and commit them in the same commit.

### 1. Clone the upstream repos

```bash
DUSKMOON_DIR=$(mktemp -d)
PHOENIX_DIR=$(mktemp -d)
ELEMENTS_DIR=$(mktemp -d)
REACT_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/duskmoon-dev/duskmoonui.git "$DUSKMOON_DIR"
git clone --depth 1 https://github.com/duskmoon-dev/phoenix-duskmoon-ui.git "$PHOENIX_DIR"
git clone --depth 1 https://github.com/duskmoon-dev/duskmoon-elements.git "$ELEMENTS_DIR"
git clone --depth 1 https://github.com/duskmoon-dev/duskmoon-react.git "$REACT_DIR"
```

### 2. Sync skills from duskmoonui

The upstream skills are in `skills/`. Copy the relevant skill directories:

```bash
PLUGIN_DIR="$(git rev-parse --show-toplevel)/plugins/duskmoon-ui"

for skill in duskmoon-dev-core duskmoon-dev-css-art; do
  if [ -d "$DUSKMOON_DIR/skills/$skill" ]; then
    rm -rf "$PLUGIN_DIR/skills/$skill"
    cp -r "$DUSKMOON_DIR/skills/$skill" "$PLUGIN_DIR/skills/$skill"
    echo "Updated skill: $skill"
  fi
done
```

### 3. Sync skills from phoenix-duskmoon-ui

```bash
for skill in phoenix-duskmoon-ui duskmoon_bundler; do
  if [ -d "$PHOENIX_DIR/skills/$skill" ]; then
    rm -rf "$PLUGIN_DIR/skills/$skill"
    cp -r "$PHOENIX_DIR/skills/$skill" "$PLUGIN_DIR/skills/$skill"
    echo "Updated skill: $skill"
  fi
done
```

### 4. Sync skills from duskmoon-elements

```bash
for skill in duskmoon-elements duskmoon-art-elements; do
  if [ -d "$ELEMENTS_DIR/skills/$skill" ]; then
    rm -rf "$PLUGIN_DIR/skills/$skill"
    cp -r "$ELEMENTS_DIR/skills/$skill" "$PLUGIN_DIR/skills/$skill"
    echo "Updated skill: $skill"
  fi
done
```

### 5. Sync skills from duskmoon-react

```bash
for skill in duskmoon-components duskmoon-art-components; do
  if [ -d "$REACT_DIR/skills/$skill" ]; then
    rm -rf "$PLUGIN_DIR/skills/$skill"
    cp -r "$REACT_DIR/skills/$skill" "$PLUGIN_DIR/skills/$skill"
    echo "Updated skill: $skill"
  fi
done
```

### 6. Clean up

```bash
rm -rf "$DUSKMOON_DIR" "$PHOENIX_DIR" "$ELEMENTS_DIR" "$REACT_DIR"
```

### 7. Report changes

Run `git diff --stat plugins/duskmoon-ui/` to show what changed.

If there are changes, stage and commit:

```
git add plugins/duskmoon-ui/
git commit -m "chore(duskmoon-ui): sync from upstream repos"
```

If no changes, report that the plugin is already up to date.

{{INPUT}}
