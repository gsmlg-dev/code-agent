---
description: Update duskmoon-ui plugin skills from upstream repos
---

Sync duskmoon-ui plugin skills from upstream sources:
- https://github.com/duskmoon-dev/duskmoonui
- https://github.com/duskmoon-dev/phoenix-duskmoon-ui
- https://github.com/duskmoon-dev/duskmoon-elements

## Steps

### 1. Clone the upstream repos

```bash
DUSKMOON_DIR=$(mktemp -d)
PHOENIX_DIR=$(mktemp -d)
ELEMENTS_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/duskmoon-dev/duskmoonui.git "$DUSKMOON_DIR"
git clone --depth 1 https://github.com/duskmoon-dev/phoenix-duskmoon-ui.git "$PHOENIX_DIR"
git clone --depth 1 https://github.com/duskmoon-dev/duskmoon-elements.git "$ELEMENTS_DIR"
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

### 3. Sync skill from phoenix-duskmoon-ui

```bash
if [ -d "$PHOENIX_DIR/skills/phoenix-duskmoon-ui" ]; then
  rm -rf "$PLUGIN_DIR/skills/phoenix-duskmoon-ui"
  cp -r "$PHOENIX_DIR/skills/phoenix-duskmoon-ui" "$PLUGIN_DIR/skills/phoenix-duskmoon-ui"
  echo "Updated skill: phoenix-duskmoon-ui"
fi
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

### 5. Clean up

```bash
rm -rf "$DUSKMOON_DIR" "$PHOENIX_DIR" "$ELEMENTS_DIR"
```

### 6. Report changes

Run `git diff --stat plugins/duskmoon-ui/` to show what changed.

If there are changes, stage and commit:

```
git add plugins/duskmoon-ui/
git commit -m "chore(duskmoon-ui): sync from upstream repos"
```

If no changes, report that the plugin is already up to date.

{{INPUT}}
