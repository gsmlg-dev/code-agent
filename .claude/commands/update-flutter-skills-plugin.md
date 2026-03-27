---
description: Update flutter-skills plugin skills from flutter/skills
---

Sync flutter-skills plugin from upstream source https://github.com/flutter/skills

All skill directories under `skills/` are copied directly, replacing local versions.

## Steps

### 1. Clone the upstream repo

```bash
UPSTREAM_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/flutter/skills.git "$UPSTREAM_DIR"
```

### 2. Sync all skills

Copy all skill directories from upstream, replacing local versions:

```bash
PLUGIN_DIR="$(git rev-parse --show-toplevel)/plugins/flutter-skills"

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

Run `git diff --stat plugins/flutter-skills/` to show what changed.

If there are changes, stage and commit:

```
git add plugins/flutter-skills/
git commit -m "chore(flutter-skills): sync from flutter/skills"
```

If no changes, report that the plugin is already up to date.

{{INPUT}}
