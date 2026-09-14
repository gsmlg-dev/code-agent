# Repository Guidelines

## Project Structure & Module Organization

This repository publishes Claude Code source plugins plus generated Codex and
Cursor bundles. The root registries are `.claude-plugin/marketplace.json`,
`.codex-plugin/marketplace.json`, and `.cursor-plugin/marketplace.json`.
Source plugins live under `plugins/<name>/`;
their `.claude-plugin/plugin.json`, `skills/`, `agents/`, hooks, and binaries
define each plugin. Generated platform output belongs under
`generated/codex-plugins/`, `generated/codex-command-skills/`, and
`generated/cursor-plugins/`; edit the source plugin rather than generated
files. Cursor output is a local adapter, not an official Cursor manifest.
Repository maintenance skills are tracked in `.agents/skills/`, while
reusable maintenance scripts are in `scripts/`.

Each `cmd-*` maintenance skill keeps an `UPDATES.md` beside `SKILL.md`.
Update workflows append the source/ref, base Git commit, target plugin, and
added/modified/deleted paths after syncing. Old files are intentionally removed
without snapshots; restore a deleted path from the logged base commit with
`git restore --source <base-commit> -- <path>`.

## Build, Test, and Development Commands

There is no application build or language test suite. Use the repository
checks before submitting changes:

```bash
node scripts/validate                 # Validate marketplace, manifests, versions, and generators
claude plugin validate .              # Validate the root marketplace with Claude Code
claude plugin validate ./plugins/<name> # Validate one plugin manifest
./scripts/set-version 0.6.3           # Synchronize marketplace/plugin/README versions
node scripts/generate-codex-plugins   # Regenerate Codex bundles
node scripts/generate-cursor-plugins  # Regenerate Cursor adapter bundles
node scripts/validate-cursor          # Validate Cursor adapter bundles
```

The GitHub workflow in `.github/workflows/test-plugins.yml` additionally
installs every published plugin from a local marketplace; use it as the model
for integration validation. Do not use the deprecated `install-codex.sh` or
`move-commands-to-skills` migration scripts for new work.

## Coding Style & Naming Conventions

Keep Markdown concise and use existing frontmatter conventions. Skill
directories and their `name` fields must match, using lowercase kebab case;
workflow skills use the `cmd-<name>` prefix. Preserve valid, consistently
indented JSON and executable shell/Node scripts. Keep version values in sync
through `scripts/set-version` rather than editing individual manifests.

## Testing Guidelines

For content or manifest changes, run `node scripts/validate` and the relevant
`claude plugin validate` commands. For generator or script changes, exercise
the affected command and inspect the generated diff. Add focused checks when
introducing new validation behavior; there is no coverage threshold.

## Commit & Pull Request Guidelines

Use Conventional Commit subjects such as `feat(plugin): ...`, `fix(marketplace): ...`,
`docs(...): ...`, or `chore: ...`. Keep commits focused and include generated
artifacts when their source changes. Pull requests should explain the affected
plugin or registry, list validation commands and results, link related issues,
and include screenshots only when documenting a user-visible CLI or rendered
change.
