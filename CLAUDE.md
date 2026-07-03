# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A Claude Code plugin marketplace. The root `.claude-plugin/marketplace.json` registers all plugins. Each plugin lives in `plugins/<name>/` and contributes one or more of: **agents** or **skills**.

Slash-command-style workflows (formerly in `commands/`) now live in `skills/cmd-<name>/SKILL.md` so they share the skill auto-discovery path. Slash commands are still wired up at runtime via the skill's `name` frontmatter.

Native Codex plugin bundles are generated from the Claude plugin sources. The root `.codex-plugin/marketplace.json` points Codex at `generated/codex-plugins/<name>/`, where existing skills (including `cmd-*` skills) are copied and Claude agents are wrapped as Codex skills.

## Repository Layout

```
.claude-plugin/marketplace.json     # Plugin registry (10 plugins)
.codex-plugin/marketplace.json      # Generated Codex plugin registry
.claude/commands/                   # Repo-local sync commands (tracked in git)
generated/codex-plugins/            # Generated native Codex plugin bundles
generated/codex-command-skills/      # Generated standalone command skill wrappers
scripts/set-version                 # Set all plugin + marketplace versions at once
plugins/
  dev-agents/      agents/                 # 8 role agents (architect, debugger, etc.)
  dev-workflow/    skills/                 # 5 cmd-* skills (git-commit, review, brainstorm, etc.)
  github/          skills/                 # 5 cmd-* skills (fix-github-actions, fix-pr-review, setup-workflows, etc.)
  phoenix-tools/   skills/                 # 2 cmd-* skills (gettext, DuskMoon setup)
  chrome-devtools/ skills/                 # 6 skills (browser automation, a11y, LCP, etc.)
  elixir-dev/      skills/ hooks/ bin/     # 12 skills + hooks + LSP (reference implementation)
  duskmoon-ui/     skills/                 # 9 skills (CSS, web components, Phoenix UI + 1 cmd-* skill)
  flutter-skills/  skills/                 # 10 Flutter development skills
  gsmlg-app/       skills/                 # 3 skills (Flutter DuskMoon + 1 cmd-* skill)
  speckit/         skills/                 # 12 cmd-* skills (Specification-Driven Development)
```

## Plugin Architecture

### Plugin types

| Type | Directory | Format | Example |
|------|-----------|--------|---------|
| Agents | `plugins/<name>/agents/` | `<role>.md` — role definition + workflow | `dev-agents` |
| Skills | `plugins/<name>/skills/<skill-name>/SKILL.md` | YAML frontmatter + content | `chrome-devtools`, `elixir-dev`, `duskmoon-ui` |

### Skill naming

- **Domain skills** (e.g. `chrome-devtools-cli`, `flutter-duskmoon`) use the natural skill name.
- **Workflow skills** (formerly slash commands) live under `skills/cmd-<kebab-name>/` and are listed in the plugin's `skills` array in `marketplace.json`. The `cmd-` prefix keeps them visually distinct from domain skills in the catalog and matches the slash-command name users type.

### Required files for every plugin

- `.claude-plugin/plugin.json` — `name`, `description`, `version`, `author`
- Entry in `.claude-plugin/marketplace.json` at the repo root

### Optional plugin features (elixir-dev is the reference implementation)

- **Hooks** — `hooks/hooks.json` + shell scripts, triggered on `SessionStart` / `PostToolUse`
- **LSP** — `bin/<wrapper>` + `lspServers` in `plugin.json`
- **MCP** — `.mcp.json` at the plugin root (dotfile), registers external MCP tool servers
- **References** — `skills/<name>/references/*.md` for supplementary docs

## Adding Content

### New skill

1. Create `plugins/<plugin>/skills/<skill-name>/SKILL.md` with frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Trigger description shown in skill list
   ---
   ```
2. Optionally add `references/` alongside it for supplementary docs.
3. Add the skill path to the plugin's `skills` array in `.claude-plugin/marketplace.json` if it should appear in the catalog.

### New workflow skill (cmd-*)

1. Create `plugins/<plugin>/skills/cmd-<name>/SKILL.md` with frontmatter:
   ```yaml
   ---
   name: cmd-<name>
   description: One-line description shown when invoking the workflow
   ---
   ```
2. Reference the user input via `{{INPUT}}` (or `$1`, `$2`, etc.) inside the body.
3. Add `./skills/cmd-<name>` to the plugin's `skills` array in `.claude-plugin/marketplace.json`.

### New plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json`
2. Add agents/skills subdirectories as needed
3. Register in `.claude-plugin/marketplace.json`
4. Run `./scripts/set-version <current-version>` to align the new plugin's version

## Versioning

All plugin versions are kept in sync with the marketplace metadata version. To bump all at once:

```bash
./scripts/set-version 0.5.0
```

This updates `marketplace.json` (metadata + all plugin entries) and every `plugins/*/.claude-plugin/plugin.json`.

## Upstream Sync Commands

Four plugins are synced from external repos via commands in `.claude/commands/`:

| Command | Source repo | Target plugin |
|---------|-------------|---------------|
| `/update-elixir-dev-plugin` | `georgeguimaraes/claude-code-elixir` | `plugins/elixir-dev` |
| `/update-duskmoon-plugin` | `duskmoon-dev/{duskmoonui,phoenix-duskmoon-ui,duskmoon-elements}` | `plugins/duskmoon-ui` |
| `/update-chrome-devtools-plugin` | `ChromeDevTools/chrome-devtools-mcp` | `plugins/chrome-devtools` |
| `/update-speckit-plugin` | `github/spec-kit` | `plugins/speckit` |

These commands clone upstream, copy skill directories (including `cmd-*` workflow skills), then commit if anything changed. The `chrome-devtools-mcp` skill is a locally extended version of upstream — the update command merges new upstream content rather than replacing it. The `elixir-dev` hooks.json is **not** overwritten by its update command — it's a locally maintained merge of multiple upstream configs.

## Key Conventions

- Skill `description` frontmatter is the trigger condition shown to Claude — write it as "Use when…"
- Skill `name` frontmatter must match the directory name (e.g. `cmd-git-commit` lives in `skills/cmd-git-commit/`)
- `.claude/commands/` (repo-local commands, not part of any plugin) are tracked in git — see `.gitignore` for the `!.claude/commands/` exception
- Version is tracked in both `marketplace.json` (metadata.version) and `README.md` — keep them in sync via `scripts/set-version`

## Commonly Used Development Commands

Because this is a marketplace of markdown and JSON configuration files, **there are no traditional build, lint, or test commands** (e.g., no Node/Python test runner).

- **Test a Plugin Locally:** Install your local directory changes into Claude Code to test:
  `claude plugin install ./plugins/<plugin-name>`
- **Set/Bump Version:** Update all manifests at once:
  `./scripts/set-version <version>` (e.g., `./scripts/set-version 0.5.7`)

## Installation Instructions (from README)

Users install the marketplace via:
`claude plugin marketplace add gsmlg-dev/code-agent`

And install individual plugins via:
`claude plugin install <plugin-name>@gsmlg-dev-code-agent`

- **Codex Integration:** Install plugins into a local Codex environment by running:
  `./scripts/install-codex.sh`
- **Native Codex Plugins:** Regenerate Codex plugin bundles with:
  `./scripts/generate-codex-plugins`
