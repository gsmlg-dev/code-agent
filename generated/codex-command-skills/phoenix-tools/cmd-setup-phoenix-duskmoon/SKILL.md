---
name: "cmd-setup-phoenix-duskmoon"
description: "Set up DuskMoon UI system in a Phoenix project — tailwindcss v4, bun bundler, phoenix_duskmoon components, and CLAUDE.md constitution"
---

# /setup-phoenix-duskmoon

Agent skill wrapper for the Claude command `/setup-phoenix-duskmoon`.

When the original command text references `{{INPUT}}`, `$1`, or named arguments, map them from the user's current request.

## Command Instructions


Set up the DuskMoon UI system in the current Phoenix project. Use the skills `duskmoon-dev-core`, `duskmoon-dev-css-art`, `duskmoon-elements`, and `phoenix-duskmoon-ui` as needed throughout these tasks.

## Tasks

### 1. Update CLAUDE.md with UI constitution

Add or update a `## UI Library` section in `./CLAUDE.md` with the following constitution:

```markdown
## UI Library

This project uses the DuskMoon UI system:

- **`phoenix_duskmoon`** — Phoenix LiveView UI component library (primary web UI)
- **`@duskmoon-dev/core`** — Core Tailwind CSS plugin and utilities
- **`@duskmoon-dev/css-art`** — CSS art utilities
- **`@duskmoon-dev/elements`** — Base web components
- **`@duskmoon-dev/art-elements`** — Art/decorative web components

Do NOT use DaisyUI or other CSS component libraries. Do NOT use `core_components.ex` — use `phoenix_duskmoon` components instead.
Use `@duskmoon-dev/core/plugin` as the Tailwind CSS plugin.

### Reporting issues or feature requests

If you encounter missing features, bugs, or need functionality not yet available in any DuskMoon package, open a GitHub issue in the appropriate repository with the label `internal request`:

- **`phoenix_duskmoon`** — https://github.com/gsmlg-dev/phoenix_duskmoon/issues
- **`@duskmoon-dev/core`** — https://github.com/gsmlg-dev/duskmoon-dev/issues
- **`@duskmoon-dev/css-art`** — https://github.com/gsmlg-dev/duskmoon-dev/issues
- **`@duskmoon-dev/elements`** — https://github.com/gsmlg-dev/duskmoon-dev/issues
- **`@duskmoon-dev/art-elements`** — https://github.com/gsmlg-dev/duskmoon-dev/issues
```

If `./CLAUDE.md` does not exist, create it with this section.

### 2. Update CSS to Tailwind CSS v4 with DuskMoon

- Upgrade to **Tailwind CSS v4** (remove v3 config if present)
- Remove **DaisyUI** from all config and dependencies if present
- Set `@duskmoon-dev/core/plugin` as the primary Tailwind CSS plugin
- Update the main CSS entry file to use Tailwind v4 `@import "tailwindcss"` syntax and import `@duskmoon-dev/core/plugin`
- Remove any `tailwind.config.js` / `tailwind.config.ts` (v3 config files); v4 is configured via CSS

### 3. Replace core_components.ex with phoenix_duskmoon

- Add `phoenix_duskmoon` to `mix.exs` dependencies if not already present
- If `core_components.ex` exists anywhere in the project:
  - Identify all callers of functions it exports
  - Replace those calls with equivalent `phoenix_duskmoon` components (use the `phoenix-duskmoon-ui` skill to map the equivalents)
  - Delete `core_components.ex` after migrating all references
- Add `import PhoenixDuskmoon.Components` (or the appropriate import) to the web module helpers so components are available everywhere
- If you find components or patterns that `phoenix_duskmoon` does not yet support, open a GitHub issue at https://github.com/gsmlg-dev/phoenix_duskmoon/issues with the label `internal request` describing the needed component

### 4. Add bunfig.toml

Check if `bunfig.toml` exists at the project root.
- If the project is an **umbrella** (has `apps/` directory), add:
  ```toml
  [install]
  optional = true

  [workspaces]
  packages = ["apps/*"]
  ```
- If the project is a **standard** Phoenix project, add a minimal `bunfig.toml`:
  ```toml
  [install]
  optional = true
  ```

### 5. Add root package.json if missing

Check if `package.json` exists at the project root.
- If the project is an **umbrella**, add a workspace-aware root `package.json`:
  ```json
  {
    "private": true,
    "workspaces": ["apps/*"]
  }
  ```
- If it is a **standard** Phoenix project and `package.json` is missing at the root (assets may have one under `assets/`), add one at the project root pointing to the assets workspace or leave it minimal as needed for bun to resolve packages.

### 6. Switch JS bundler from esbuild to bun + tailwind standalone CLI

In `mix.exs` deps, replace `{:esbuild, ...}` with:

```elixir
{:bun, "~> 1.4", runtime: Mix.env() == :dev},
{:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
```

In `config/config.exs`, replace the `config :esbuild` block with (use the actual app name, not `my_app`):

```elixir
config :bun,
  version: "1.3.4",
  my_app: [
    args: ~w(build assets/js/app.js --outdir=priv/static/assets --external /fonts/* --external /images/*),
    cd: Path.expand("../", __DIR__)
  ]

config :tailwind,
  version: "4.1.11",
  my_app: [
    args: ~w(--input=assets/css/app.css --output=priv/static/assets/app.css),
    cd: Path.expand("../", __DIR__)
  ]
```

For umbrella apps, use `Path.expand("../apps/my_app", __DIR__)` for `cd:`.

In `config/dev.exs`, replace the esbuild watcher with:

```elixir
watchers: [
  tailwind: {Tailwind, :install_and_run, [:my_app, ~w(--watch)]},
  bun: {Bun, :install_and_run, [:my_app, ~w(--sourcemap=inline --watch)]}
]
```

Update `mix.exs` aliases:

```elixir
"assets.deploy": [
  "phx.digest.clean",
  "tailwind my_app --minify",
  "bun my_app --minify",
  "phx.digest"
]
```

### 7. Set NODE_PATH for Phoenix dependency resolution

Set `NODE_PATH` to the project root's `deps/` directory so Bun resolves Phoenix JS packages
(`phoenix`, `phoenix_html`, `phoenix_live_view`, etc.) directly from Elixir's `deps/` without
needing `npm install`.

In `devenv.nix` (if present), this is already set via:
```nix
env.NODE_PATH = "${config.git.root}/deps";
```

For non-devenv setups, export in shell or CI:
```bash
export NODE_PATH="$(pwd)/deps"
```

No `npm install` or symlinks needed for Phoenix's own JS packages.

### 8. Configure runtime.exs for devenv binary paths

In `config/runtime.exs`, add so devenv-provided system binaries are used instead of downloaded ones:

```elixir
if System.get_env("MIX_BUN_PATH") do
  config :bun, path: System.get_env("MIX_BUN_PATH")
end

if System.get_env("MIX_TAILWIND_PATH") do
  config :tailwind, path: System.get_env("MIX_TAILWIND_PATH")
end
```

### 9. Update assets/package.json for DuskMoon JS packages

Ensure `assets/package.json` (or the relevant workspace `package.json`) lists the DuskMoon packages as dependencies:

```json
{
  "dependencies": {
    "@duskmoon-dev/core": "latest",
    "@duskmoon-dev/css-art": "latest",
    "@duskmoon-dev/elements": "latest",
    "@duskmoon-dev/art-elements": "latest"
  }
}
```

Remove any `esbuild` or `daisyui` entries from the package.json.

### 10. Install dependencies

After all file changes are made:
1. Run `mix deps.get` to fetch new hex packages
2. Run `bun install` (from project root) to install JS packages

### 11. Report missing features as internal requests

After completing the migration, review any gaps encountered:
- If a DuskMoon package is missing a feature, component, or has a bug that blocked or complicated this migration, open a GitHub issue in the relevant repository with the label `internal request`:
  - **`phoenix_duskmoon`** issues → https://github.com/gsmlg-dev/phoenix_duskmoon/issues
  - **`@duskmoon-dev/core`**, **`@duskmoon-dev/css-art`**, **`@duskmoon-dev/elements`**, **`@duskmoon-dev/art-elements`** issues → https://github.com/gsmlg-dev/duskmoon-dev/issues
- Include in the issue: a clear description of the missing/broken functionality, the use case, and (if possible) a suggested API or workaround

## Important Notes

- Always read files before modifying them
- Use the relevant DuskMoon skills for precise API details:
  - `duskmoon-dev-core` for Tailwind plugin setup and core utilities
  - `duskmoon-dev-css-art` for CSS art package usage
  - `duskmoon-elements` for base web component APIs
  - `phoenix-duskmoon-ui` for Phoenix component mappings
- Preserve all existing business logic — only replace UI infrastructure
- After migration, do a project-wide search for any remaining references to `esbuild`, `DaisyUI`, or `CoreComponents` and clean them up
