---
description: Update elixir-dev skills from georgeguimaraes/claude-code-elixir
---

Sync elixir-dev plugin skills from upstream source https://github.com/georgeguimaraes/claude-code-elixir

## Steps

### 1. Clone or fetch the upstream repo

```bash
UPSTREAM_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/georgeguimaraes/claude-code-elixir.git "$UPSTREAM_DIR"
```

### 2. Copy thinking skills into elixir-dev plugin

The upstream skills are in `plugins/elixir/skills/`. Copy all skill directories:

```bash
PLUGIN_DIR="$(git rev-parse --show-toplevel)/plugins/elixir-dev/skills"

# Copy each thinking skill (preserving references/ subdirs)
for skill in elixir-thinking phoenix-thinking ecto-thinking otp-thinking oban-thinking using-elixir-skills; do
  if [ -d "$UPSTREAM_DIR/plugins/elixir/skills/$skill" ]; then
    rm -rf "$PLUGIN_DIR/$skill"
    cp -r "$UPSTREAM_DIR/plugins/elixir/skills/$skill" "$PLUGIN_DIR/$skill"
    echo "Updated: $skill"
  fi
done
```

### 3. Clean up

```bash
rm -rf "$UPSTREAM_DIR"
```

### 4. Report changes

Run `git diff --stat` on the elixir-dev plugin to show what changed.

If there are changes, stage and commit:

```
git add plugins/elixir-dev/skills/
git commit -m "chore(elixir-dev): sync skills from georgeguimaraes/claude-code-elixir"
```

If no changes, report that skills are already up to date.

{{INPUT}}
