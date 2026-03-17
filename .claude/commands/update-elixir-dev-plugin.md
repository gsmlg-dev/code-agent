---
description: Update elixir-dev plugin from georgeguimaraes/claude-code-elixir
---

Sync elixir-dev plugin (skills, hooks, LSP) from multiple upstream sources:
- https://github.com/georgeguimaraes/claude-code-elixir — thinking skills, hooks, LSP
- https://github.com/gsmlg-dev/denox — denox skill

## Steps

### 1. Clone the upstream repo

```bash
UPSTREAM_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/georgeguimaraes/claude-code-elixir.git "$UPSTREAM_DIR"
```

### 2. Sync thinking skills

The upstream skills are in `plugins/elixir/skills/`. Copy all skill directories:

```bash
PLUGIN_DIR="$(git rev-parse --show-toplevel)/plugins/elixir-dev"

for skill in elixir-thinking phoenix-thinking ecto-thinking otp-thinking oban-thinking using-elixir-skills; do
  if [ -d "$UPSTREAM_DIR/plugins/elixir/skills/$skill" ]; then
    rm -rf "$PLUGIN_DIR/skills/$skill"
    cp -r "$UPSTREAM_DIR/plugins/elixir/skills/$skill" "$PLUGIN_DIR/skills/$skill"
    echo "Updated skill: $skill"
  fi
done
```

### 3. Sync hook scripts

Copy hook shell scripts from the upstream plugins (elixir, mix-format, mix-compile, mix-credo):

```bash
cp "$UPSTREAM_DIR/plugins/elixir/hooks/session-start.sh" "$PLUGIN_DIR/hooks/"
cp "$UPSTREAM_DIR/plugins/elixir/hooks/run-hook.cmd" "$PLUGIN_DIR/hooks/"
cp "$UPSTREAM_DIR/plugins/mix-format/hooks/format-elixir.sh" "$PLUGIN_DIR/hooks/"
cp "$UPSTREAM_DIR/plugins/mix-compile/hooks/compile-elixir.sh" "$PLUGIN_DIR/hooks/"
cp "$UPSTREAM_DIR/plugins/mix-credo/hooks/credo-elixir.sh" "$PLUGIN_DIR/hooks/"
chmod +x "$PLUGIN_DIR/hooks/"*.sh "$PLUGIN_DIR/hooks/run-hook.cmd"
echo "Updated hook scripts"
```

Note: Do NOT overwrite `hooks/hooks.json` — we maintain our own merged version combining all upstream hook configs.

### 4. Sync LSP wrapper

```bash
cp "$UPSTREAM_DIR/plugins/elixir-lsp/bin/expert-wrapper" "$PLUGIN_DIR/bin/"
chmod +x "$PLUGIN_DIR/bin/expert-wrapper"
echo "Updated LSP wrapper"
```

### 5. Sync denox skill

Clone the denox repo and copy its skill into the elixir-dev plugin:

```bash
DENOX_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/gsmlg-dev/denox.git "$DENOX_DIR"

rm -rf "$PLUGIN_DIR/skills/denox"
cp -r "$DENOX_DIR/skills/denox" "$PLUGIN_DIR/skills/denox"
echo "Updated skill: denox"

rm -rf "$DENOX_DIR"
```

### 6. Clean up

```bash
rm -rf "$UPSTREAM_DIR"
```

### 7. Report changes

Run `git diff --stat plugins/elixir-dev/` to show what changed.

If there are changes, stage and commit:

```
git add plugins/elixir-dev/
git commit -m "chore(elixir-dev): sync from upstream sources"
```

If no changes, report that the plugin is already up to date.

{{INPUT}}
