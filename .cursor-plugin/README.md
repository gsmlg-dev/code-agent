# Cursor Adapter Format

This directory contains a repository-local adapter for Cursor. It is **not** an
official Cursor marketplace format (`officialCompatibility` is deliberately
`false`) because this repository does not currently verify a stable public
Cursor plugin schema.

Run `node scripts/generate-cursor-plugins` after changing a source plugin. The
generator reads `plugins/*` and writes one bundle per entry in
`marketplace.json` under `generated/cursor-plugins/`.

Each bundle contains:

- `skills/`: copied skill directories, the portable capability consumed by this
  adapter.
- `.cursor-plugin/plugin.json`: adapter manifest with `format`, identity,
  `capabilities.skills`, and a complete `capabilities.inventory` for agents,
  commands, hooks, MCP, and LSP.
- `unsupported/<capability>/`: source files for capabilities that are present
  but have no verified Cursor equivalent. Each such capability is also listed
  in `capabilities.unsupported` with a reason and source path.

Validate generated output with `node scripts/validate-cursor`. Generated files
are release artifacts; edit the source plugin rather than a bundle.
