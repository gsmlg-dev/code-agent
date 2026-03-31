---
description: Update gsmlg-app plugin skills from duskmoon-dev/flutter-duskmoon-ui
---

Sync gsmlg-app plugin from upstream source https://github.com/duskmoon-dev/flutter-duskmoon-ui

All skill directories under `skills/` are copied directly, replacing local versions.

## Steps

### 1. Clone the upstream repo

```bash
UPSTREAM_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/duskmoon-dev/flutter-duskmoon-ui.git "$UPSTREAM_DIR"
```

### 2. Sync all skills

Copy all skill directories from upstream, replacing local versions:

```bash
PLUGIN_DIR="$(git rev-parse --show-toplevel)/plugins/gsmlg-app"

for skill_dir in "$UPSTREAM_DIR/skills"/*/; do
  skill=$(basename "$skill_dir")
  rm -rf "$PLUGIN_DIR/skills/$skill"
  cp -r "$skill_dir" "$PLUGIN_DIR/skills/$skill"
  echo "Updated skill: $skill"
done
```

### 3. Clean up

```bash
rm -rf "$UPSTREAM_DIR"
```

### 4. Report changes

Run `git diff --stat plugins/gsmlg-app/` to show what changed.

If there are changes, stage and commit:

```
git add plugins/gsmlg-app/
git commit -m "chore(gsmlg-app): sync from duskmoon-dev/flutter-duskmoon-ui"
```

If no changes, report that the plugin is already up to date.

{{INPUT}}
