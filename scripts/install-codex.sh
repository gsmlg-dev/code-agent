#!/usr/bin/env bash
set -euo pipefail

CODEX_DIR="${HOME}/.codex"
CODEX_SKILLS_DIR="${CODEX_DIR}/skills"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Installing code-agent plugins to Codex..."
mkdir -p "$CODEX_SKILLS_DIR"

# 1. Install Skills (including cmd-* skills that were previously commands)
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

echo ""
echo "Installation to Codex complete!"
echo "You can now use these plugins in Codex. Skills (including cmd-* workflow skills) are available."
