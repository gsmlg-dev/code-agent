---
name: "cmd-setup-phoenix-duskmoon"
description: Set up DuskMoon UI system in a Phoenix project — tailwindcss v4, duskmoon_bundler, phoenix_duskmoon components, and CLAUDE.md constitution
---

Set up the DuskMoon UI system in the current Phoenix project. Use the skills `duskmoon-dev-core`, `duskmoon-dev-css-art`, `duskmoon-elements`, `duskmoon_bundler`, and `phoenix-duskmoon-ui` as needed throughout these tasks.

`duskmoon_bundler` is an Elixir-native frontend toolchain (Rust NIFs powered by OXC/LightningCSS/QuickBEAM) that replaces `esbuild`, the Tailwind CLI binary, `bun`, and Node.js entirely — no external binaries to download. `duskmoon_npm` (its transitive dependency) provides `mix npm.*` tasks for managing `node_modules` packages without a real npm/Node install.

## Tasks

### 1. Update CLAUDE.md with UI constitution

Add or update a `## UI Library` section in `./CLAUDE.md` with the following constitution:

```markdown
## UI Library

This project uses the DuskMoon UI system:

- **`phoenix_duskmoon`** — Phoenix LiveView UI component library (primary web UI)
- **`duskmoon_bundler`** / **`duskmoon_bundler_runtime`** — Elixir-native asset bundler (replaces esbuild/tailwind CLI/bun/Node.js)
- **`@duskmoon-dev/core`** — Core Tailwind CSS plugin and utilities
- **`@duskmoon-dev/css-art`** — CSS art utilities
- **`@duskmoon-dev/elements`** — Base web components
- **`@duskmoon-dev/art-elements`** — Art/decorative web components

Do NOT use DaisyUI or other CSS component libraries. Do NOT use `core_components.ex` — use `phoenix_duskmoon` components instead.
Use `@duskmoon-dev/core/plugin` as the Tailwind CSS plugin.
Do NOT add `esbuild`, `tailwind`, or `bun` mix deps, or a Node.js toolchain — `duskmoon_bundler` replaces all of them.

### Reporting issues or feature requests

If you encounter missing features, bugs, or need functionality not yet available in any DuskMoon package, open a GitHub issue in the appropriate repository with the label `internal request`:

- **`phoenix_duskmoon`** — https://github.com/gsmlg-dev/phoenix_duskmoon/issues
- **`duskmoon_bundler`** / **`duskmoon_bundler_runtime`** / **`duskmoon_npm`** — https://github.com/gsmlg-dev/duskmoon-dev/issues
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
- Remove any `tailwind.config.js` / `tailwind.config.ts` (v3 config files); v4 is configured via CSS and the `tailwind:` key in `duskmoon_bundler` config (see Task 5)

Example `assets/css/app.css`:

```css
@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
@import "@duskmoon-dev/core/themes/sunshine";
@import "@duskmoon-dev/core/themes/moonlight";
@import "@duskmoon-dev/core/components";

@source "../js";
@source "../../lib/my_app_web";
@source "../../deps/phoenix_duskmoon/lib/phoenix_duskmoon/";
```

### 3. Replace core_components.ex with phoenix_duskmoon

- Add `phoenix_duskmoon` to `mix.exs` dependencies if not already present
- If `core_components.ex` exists anywhere in the project:
  - Identify all callers of functions it exports
  - Replace those calls with equivalent `phoenix_duskmoon` components (use the `phoenix-duskmoon-ui` skill to map the equivalents)
  - Delete `core_components.ex` after migrating all references
- Add `import PhoenixDuskmoon.Components` (or the appropriate import) to the web module helpers so components are available everywhere
- If you find components or patterns that `phoenix_duskmoon` does not yet support, open a GitHub issue at https://github.com/gsmlg-dev/phoenix_duskmoon/issues with the label `internal request` describing the needed component

### 4. Switch dependencies from esbuild/tailwind/bun to duskmoon_bundler

In `mix.exs` deps, remove any of `{:esbuild, ...}`, `{:tailwind, ...}`, `{:bun, ...}` and add:

```elixir
{:duskmoon_bundler_runtime, "~> 9.7"},
{:duskmoon_bundler, "~> 9.7", runtime: Mix.env() == :dev}
```

Do **not** use `only: :dev` for `:duskmoon_bundler` — production asset build aliases (`assets.deploy`) may run under `MIX_ENV=prod`. The `runtime:` option keeps the build/dev tooling out of production releases while keeping its Mix tasks available.

If `igniter` is already a dependency (or the user is fine adding it temporarily), prefer running the automatic installer instead of the manual steps below:

```bash
mix igniter.install duskmoon_bundler
```

This adds the deps, configures `config/config.exs`, adds the `.formatter.exs` plugin, adds the `DuskmoonBundler.DevServer` plug to the endpoint, adds the watcher to `config/dev.exs`, updates `assets.build`/`assets.deploy` aliases, and removes `esbuild`/`tailwind` deps automatically. Still verify the result against Tasks 5–8 below, especially for umbrella apps with multiple endpoints, which the installer does not handle.

### 5. Configure duskmoon_bundler in config.exs

Replace any `config :esbuild` / `config :tailwind` blocks in `config/config.exs` with (use the actual app name, not `my_app`):

```elixir
config :duskmoon_bundler,
  resolve_dirs: ["node_modules", "deps"],
  target: :es2020,
  sourcemap: :hidden

config :duskmoon_bundler, :my_app,
  entry: "assets/js/app.js",
  outdir: "priv/static/assets",
  root: "assets",
  asset_url_prefix: "/assets",
  tailwind: [
    css: "assets/css/app.css",
    sources: [
      %{base: "lib/my_app_web", pattern: "**/*.{ex,heex}"},
      %{base: "deps/phoenix_duskmoon/lib/phoenix_duskmoon", pattern: "**/*.{ex,heex}"},
      %{base: "assets", pattern: "**/*.{js,css}"}
    ]
  ],
  server: [
    prefix: "/assets",
    watch_dirs: ["lib/my_app_web", "assets"]
  ]
```

If the previous esbuild setup relied on `NODE_PATH` to resolve packages outside `node_modules` (e.g. Phoenix's own JS packages from `deps/`), add those directories to `resolve_dirs` instead — `resolve_dirs: ["node_modules", "deps"]` covers the common case. `NODE_PATH` is no longer needed; delete any export of it from shell profiles, `devenv.nix`, or CI config.

**Umbrella apps with multiple endpoints** (e.g. a public app + an admin app in one release): configure one named profile per endpoint under `config :duskmoon_bundler, :<profile_name>, [...]`, each with its own `entry`, `outdir`, `asset_url_prefix`, and `tailwind.css`. See `duskmoon_bundler`'s own guides and the real-world example at `duskmoon_bundler`'s getting-started guide for the single-endpoint case; for the multi-endpoint pattern, mirror how `phoenix_duskmoon`/`duskmoon_bundler`-based umbrella apps configure two profiles and two watcher entries (one per endpoint) as shown in Task 6.

### 6. Add the DevServer plug and dev watcher

In each endpoint module (`lib/my_app_web/endpoint.ex`), add the dev server plug inside the `code_reloading?` block, after `Phoenix.CodeReloader`:

```elixir
if code_reloading? do
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  plug Phoenix.CodeReloader
  plug DuskmoonBundler.DevServer, root: "assets"
end
```

For an umbrella app with multiple endpoints, pass `profile:` matching the named config from Task 5, e.g. `plug DuskmoonBundler.DevServer, root: "assets", profile: :my_app_admin`.

In `config/dev.exs`, replace the esbuild/tailwind/bun watchers with the DuskmoonBundler watcher:

```elixir
config :my_app, MyAppWeb.Endpoint,
  watchers: [
    duskmoon_bundler: {Mix.Tasks.DuskmoonBundler.Dev, :run, [~w(--tailwind)]}
  ]
```

For an umbrella app with **multiple endpoints that must each run their own watcher**, wrap `DuskmoonBundler.Watcher.start_link/1` in a small module so each watcher process gets a distinct registered name:

```elixir
defmodule MyApp.Assets.DuskmoonBundlerWatcher do
  @moduledoc false

  def run(opts) when is_list(opts) do
    case DuskmoonBundler.Watcher.start_link(opts) do
      {:ok, _pid} -> Process.sleep(:infinity)
      {:error, {:already_started, _pid}} -> Process.sleep(:infinity)
      {:error, reason} -> raise "failed to start DuskmoonBundler watcher: #{inspect(reason)}"
    end
  end
end
```

```elixir
# config/dev.exs
my_app_watcher = [
  name: MyAppWeb.DuskmoonBundlerWatcher,
  root: "assets",
  watch_dirs: ["lib/my_app_web", "assets"],
  tailwind: true,
  tailwind_css: "assets/css/app.css",
  tailwind_outdir: "priv/static/assets/css",
  target: :es2020
]

config :my_app, MyAppWeb.Endpoint,
  watchers: [
    duskmoon_bundler: {MyApp.Assets.DuskmoonBundlerWatcher, :run, [my_app_watcher]}
  ]
```

### 7. Update mix.exs aliases

```elixir
defp aliases do
  [
    "assets.build": ["duskmoon_bundler.build --tailwind"],
    "assets.deploy": ["duskmoon_bundler.build --tailwind", "phx.digest"]
  ]
end
```

For umbrella apps with multiple profiles, pass the profile name as an argument, e.g. `"cmd mix duskmoon_bundler.build my_app --tailwind"` and `"cmd mix duskmoon_bundler.build my_app_admin --tailwind"` for both `assets.build` and `assets.deploy`.

### 8. Update root layout asset tags

In the root layout(s), use the `DuskmoonBundler.static_path/2` and `DuskmoonBundler.Preload.tags/2` helpers from `duskmoon_bundler_runtime` instead of hardcoded `/assets/...` paths:

```heex
<link phx-track-static rel="stylesheet" href={DuskmoonBundler.static_path(@endpoint, "/assets/css/app.css")} />
<script defer phx-track-static type="module" src={DuskmoonBundler.static_path(@endpoint, "/assets/js/app.js")}></script>
<%= DuskmoonBundler.Preload.tags(@endpoint, "/assets/js/app.js") %>
```

These resolve to source file paths in dev and content-hashed manifest paths in production, so `mix phx.digest` output is picked up automatically.

### 9. Add root package.json for DuskMoon npm packages

Check if `package.json` exists at the project root (not `assets/package.json` — `duskmoon_bundler` resolves `node_modules` from the project root via `resolve_dirs`).

- If the project is an **umbrella**, add a workspace-aware root `package.json`:
  ```json
  {
    "name": "my_app",
    "type": "module",
    "private": true,
    "dependencies": {
      "@duskmoon-dev/core": "latest",
      "@duskmoon-dev/css-art": "latest",
      "@duskmoon-dev/elements": "latest",
      "@duskmoon-dev/art-elements": "latest"
    }
  }
  ```
- If it is a **standard** Phoenix project, add the same shape without a workspaces field.

Remove any `esbuild`, `daisyui`, or `bun`-specific entries (e.g. `bunfig.toml`) from the project — none of these are needed anymore.

### 10. Install dependencies

After all file changes are made:
1. Run `mix deps.get` to fetch new hex packages
2. Run `mix npm.install` (provided by `duskmoon_npm`, a transitive dep of `duskmoon_bundler`) to install JS packages — no Node.js or bun required

### 11. Report missing features as internal requests

After completing the migration, review any gaps encountered:
- If a DuskMoon package is missing a feature, component, or has a bug that blocked or complicated this migration, open a GitHub issue in the relevant repository with the label `internal request`:
  - **`phoenix_duskmoon`** issues → https://github.com/gsmlg-dev/phoenix_duskmoon/issues
  - **`duskmoon_bundler`**, **`duskmoon_bundler_runtime`**, **`duskmoon_npm`**, **`@duskmoon-dev/core`**, **`@duskmoon-dev/css-art`**, **`@duskmoon-dev/elements`**, **`@duskmoon-dev/art-elements`** issues → https://github.com/gsmlg-dev/duskmoon-dev/issues
- Include in the issue: a clear description of the missing/broken functionality, the use case, and (if possible) a suggested API or workaround

## Important Notes

- Always read files before modifying them
- Use the relevant DuskMoon skills for precise API details:
  - `duskmoon-dev-core` for Tailwind plugin setup and core utilities
  - `duskmoon-dev-css-art` for CSS art package usage
  - `duskmoon-elements` for base web component APIs
  - `phoenix-duskmoon-ui` for Phoenix component mappings
  - `duskmoon_bundler`'s own guides (getting-started, migration from esbuild, features/tailwind) for bundler config details
- Preserve all existing business logic — only replace UI infrastructure
- After migration, do a project-wide search for any remaining references to `esbuild`, `bun`, `bunfig.toml`, `DaisyUI`, `NODE_PATH`, or `CoreComponents` and clean them up
- Delete any cached esbuild/tailwind/bun binaries: `rm -rf _build/esbuild* _build/tailwind* _build/bun*`
