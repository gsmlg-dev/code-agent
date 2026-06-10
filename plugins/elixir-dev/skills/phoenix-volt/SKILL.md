---
name: phoenix-volt
description: Set up the Volt asset pipeline in a Phoenix/Phoenix LiveView project, replacing the default esbuild + Tailwind CLI watchers with a single Elixir dependency. Use this whenever a user wants to add Volt to a Phoenix app, migrate a Phoenix project off esbuild/tailwind binaries, configure `config :volt`, wire up `Volt.DevServer` and `Volt.static_path/2`, set up `mix volt.build`/`volt.dev` watchers, or asks to "set up assets like the ess/storage-service project". Also use when bundling `@duskmoon-dev/elements` for Volt in an umbrella app. Trigger even if the user only says "add Volt", "use Volt for assets", or "get rid of esbuild and tailwind CLI in my Phoenix app".
---

# Phoenix + Volt asset pipeline

## What Volt is and why use it

Volt is Vite-level frontend tooling that runs entirely inside the BEAM. One Elixir
dependency (powered by Rust NIFs via OXC and LightningCSS) replaces three things a
default Phoenix app ships with:

- `esbuild` (JS bundler binary)
- the `tailwind` CLI binary
- Node.js for any non-vanilla JS

`mix phx.server` starts the toolchain automatically — Tailwind rebuilds in ~40ms on
template changes, JS hot-swaps via HMR, and compile errors show as a browser overlay.
There is **no `vite.config.js` and no `tailwind.config.js`** — everything is
configured in `config/*.exs`.

This skill reproduces the exact setup used in the ExStorageService (`ex_storage_service`)
umbrella project. Use the same shape for any Phoenix app.

## Fastest path: the Igniter installer

If the project has Igniter available, prefer letting Volt configure itself:

```bash
mix igniter.install volt
mix phx.server
```

The installer wires up deps, config, the endpoint plug, watchers, and the layout. Only
fall back to the manual steps below when Igniter isn't an option, when you're migrating
an existing custom setup, or when the user wants to understand/verify each piece.

## Manual setup checklist

Work through these in order. Paths assume a single Phoenix app; for umbrella layout
notes and the DuskMoon element-bundling workaround, read
`references/duskmoon-umbrella.md`.

### 1. Add the dependency

In the web app's `mix.exs`, add Volt and **remove** `esbuild` and `tailwind`
(Volt replaces both):

```elixir
{:volt, "~> 0.14"}
```

Run `mix deps.get`.

### 2. Configure Volt in `config/config.exs`

Volt needs an entry point, an output dir, where to resolve modules from, and the
Tailwind CSS entry:

```elixir
config :volt,
  entry: "assets/js/app.js",
  root: "assets",
  outdir: "priv/static/assets",
  resolve_dirs: ["deps", "node_modules"],
  target: :es2022,
  tailwind: [css: "assets/css/app.css"]
```

Declare **which files Tailwind scans for classes** in `app.css` with Tailwind v4
`@source` directives (step 7) — keep content globs there, in one place. (`config :volt,
tailwind:` also accepts a `sources:` list, but splitting globs across the CSS and the
Elixir config is the main way these setups drift.)

In an umbrella, use `Path.expand(..., __DIR__)` for every path so they resolve from the
umbrella root regardless of where `mix` runs — see the reference file for the exact form.

### 3. Configure the dev server and watcher in `config/dev.exs`

Replace the esbuild/tailwind `watchers:` entries on the endpoint with Volt's dev task,
and add the Volt dev-server config:

```elixir
config :my_app_web, MyAppWeb.Endpoint,
  watchers: [
    volt:
      {Mix.Tasks.Volt.Dev, :run,
       [~w(--tailwind --tailwind-outdir) ++ ["priv/static/assets/css"]]}
  ]

config :volt, :server,
  prefix: "/assets",
  watch_dirs: ["lib/"]

config :volt, sourcemap: :linked
```

Keep `phoenix_live_reload` for `.ex`/`.heex` changes; Volt handles JS/CSS.

### 4. Add `Volt.DevServer` to the endpoint

Inside the `code_reloading?` block in `lib/my_app_web/endpoint.ex`, after the
`Phoenix.CodeReloader` plug:

```elixir
if code_reloading? do
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader
  plug Volt.DevServer
end
```

`Plug.Static` stays as-is; make sure `assets` is in `static_paths/0`.

### 5. Reference assets with `Volt.static_path/2` in the root layout

In `root.html.heex`, swap the default `~p"/assets/..."` references for `Volt.static_path/2`.
This resolves to live source files in dev and content-hashed paths in production:

```heex
<link phx-track-static rel="stylesheet"
  href={Volt.static_path(MyAppWeb.Endpoint, "/assets/css/app.css")} />
<script defer phx-track-static type="module"
  src={Volt.static_path(MyAppWeb.Endpoint, "/assets/js/app.js")}>
</script>
```

### 6. Update mix aliases

Drop the `esbuild`/`tailwind` install and build steps. The build step is `volt.build`:

```elixir
defp aliases do
  [
    setup: ["deps.get", "assets.setup", "assets.build"],
    "assets.setup": ["npm.install"],
    "assets.build": ["volt.build --tailwind"],
    "assets.deploy": ["volt.build --tailwind", "phx.digest"]
  ]
end
```

`mix npm.install` (provided by Volt's `npm_ex` integration) installs the npm packages
listed in `package.json` without running lifecycle scripts. Only needed if you depend on
npm packages (e.g. a CSS plugin).

### 7. App entry files

`assets/js/app.js` is a normal LiveView entry — Volt bundles it directly, no esbuild
config:

```js
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
});
liveSocket.connect();
window.liveSocket = liveSocket;
```

`assets/css/app.css` uses Tailwind v4's CSS-first config (`@import "tailwindcss"`,
`@plugin`, `@source`) — no `tailwind.config.js`:

```css
@import "tailwindcss";
@source "../../lib/my_app_web/**/*.{ex,heex}";
@source "../js/**/*.js";
```

## Verify it works

Run these and confirm clean output before declaring success:

```bash
mix deps.get
mix assets.build          # should produce hashed files in priv/static/assets
mix phx.server            # Volt watcher starts; edit a .heex and watch Tailwind rebuild
```

For a production build, `mix volt.build --tailwind` then `mix phx.digest` should
finish in well under a second and emit a `manifest.json`.

## Useful Volt commands

| Command | Purpose |
|---|---|
| `mix volt.build` | Production bundle (add `--tailwind` to also build CSS) |
| `mix volt.dev` | Dev watcher (normally run via the endpoint `watchers:`) |
| `mix volt.lint` | Run oxlint (650+ rules) on JS/TS |
| `mix volt.js.check` | Format + lint, for CI (`--type-aware --type-check` for TS types) |
| `mix npm.install` | Install npm deps from `package.json` (no lifecycle scripts) |

`mix format` also formats JS/TS if you add `plugins: [Volt.Formatter]` to `.formatter.exs`.

## When the project also uses DuskMoon (or is an umbrella)

The ExStorageService project pairs Volt with `phoenix_duskmoon` and `@duskmoon-dev`
custom elements, which in an umbrella needs a small pre-bundling workaround
(`mix duskmoon.bundle`). If the target project uses DuskMoon, or is an umbrella, read
`references/duskmoon-umbrella.md` for the exact config, the bundling Mix task, and the
`app.js`/`app.css` content that imports the pre-bundled elements.
