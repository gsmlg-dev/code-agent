#!/usr/bin/env bash
set -euo pipefail

CODEX_DIR="${HOME}/.codex"
CODEX_SKILLS_DIR="${CODEX_DIR}/skills"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Installing code-agent plugins to Codex..."
mkdir -p "$CODEX_SKILLS_DIR"

# 1. Install Skills
echo -e "\n=== Installing Skills ==="
for plugin in "$REPO_ROOT"/plugins/*; do
  if [ -d "$plugin/skills" ]; then
    for skill_dir in "$plugin/skills"/*/; do
      # Remove trailing slash
      skill_dir=${skill_dir%/}
      skill_name=$(basename "$skill_dir")
      target="$CODEX_SKILLS_DIR/$skill_name"
      
      # Remove existing dir/symlink if it exists
      rm -rf "$target"
      
      # Create symlink
      ln -s "$skill_dir" "$target"
      echo "✅ Linked skill: $skill_name"
    done
  fi
done

# 2. Install Commands (Wrapped as Codex Skills)
echo -e "\n=== Installing Commands as Skills ==="
for plugin in "$REPO_ROOT"/plugins/*; do
  if [ -d "$plugin/commands" ]; then
    for cmd_file in "$plugin/commands"/*.md; do
      cmd_name=$(basename "$cmd_file" .md)
      wrapper_dir="$CODEX_SKILLS_DIR/cmd-${cmd_name}"
      
      rm -rf "$wrapper_dir"
      mkdir -p "$wrapper_dir"
      
      # Codex expects SKILL.md inside the directory. 
      # We symlink the command markdown to SKILL.md inside a wrapper directory.
      ln -s "$cmd_file" "$wrapper_dir/SKILL.md"
      echo "✅ Linked command: cmd-$cmd_name"
    done
  fi
done

echo ""
echo "Installation to Codex complete!"
echo "You can now use these plugins in Codex. Commands are available with the 'cmd-' prefix."
