---
name: cmd-update-gsmlg-app-plugin
disable-model-invocation: true
description: Update gsmlg-app plugin skills from duskmoon-dev/flutter-duskmoon-ui
---

Sync gsmlg-app plugin from upstream source https://github.com/duskmoon-dev/flutter-duskmoon-ui

All skill directories under `skills/` are copied directly, replacing local versions.

## Steps

### 0. Capture the update baseline

Before changing files, record the repository state and log path:

```bash
BASE_COMMIT=$(git rev-parse HEAD)
LOG_FILE="$(git rev-parse --show-toplevel)/.agents/skills/cmd-update-gsmlg-app-plugin/UPDATES.md"
```

After the clone and sync steps, and before cleanup, capture the upstream ref and file-level changes:

```bash
UPSTREAM_REF=$(git -C "$UPSTREAM_DIR" rev-parse HEAD)
git diff --name-status "$BASE_COMMIT" -- plugins/gsmlg-app/
```

Append a dated entry to `"$LOG_FILE"` with the source URL/ref, `BASE_COMMIT`, target, Added/Modified/Deleted counts, and each changed path. Include this restore command for deleted paths: `git restore --source <base-commit> -- plugins/gsmlg-app/<path>`. Stage the log together with plugin changes and commit them in the same commit.

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
