# Volt in an umbrella + DuskMoon elements

This file covers the two project-specific wrinkles in the ExStorageService setup:
running Volt inside an **umbrella** project, and pre-bundling `@duskmoon-dev/elements`
so Volt can serve them.

## Umbrella path handling

In an umbrella, `mix` may run from the umbrella root or from inside an app, so every
Volt path must be absolute. Resolve them from the **umbrella root's** `config/` directory
with `Path.expand(..., __DIR__)`. This is the exact `config/config.exs` block from the
project (web app named `ex_storage_service_web`):

```elixir
config :volt,
  entry: Path.expand("../apps/ex_storage_service_web/assets/js/app.js", __DIR__),
  root: Path.expand("../apps/ex_storage_service_web/assets", __DIR__),
  outdir: Path.expand("../apps/ex_storage_service_web/priv/static/assets", __DIR__),
  resolve_dirs: [Path.expand("../deps", __DIR__), Path.expand("../node_modules", __DIR__)],
  target: :es2022,
  tailwind: [css: Path.expand("../apps/ex_storage_service_web/assets/css/app.css", __DIR__)]
```

As in the single-app case, Tailwind content globs live in `app.css` via `@source` (see
the DuskMoon `app.css` below) — including the `@source` that scans the `phoenix_duskmoon`
dep so its component classes aren't purged.

`config/dev.exs` likewise expands the watcher's tailwind outdir and the dev server's
`watch_dirs` from the umbrella root:

```elixir
config :ex_storage_service_web, ExStorageServiceWeb.Endpoint,
  watchers: [
    volt:
      {Mix.Tasks.Volt.Dev, :run,
       [
         ~w(--tailwind --tailwind-outdir) ++
           [Path.expand("../apps/ex_storage_service_web/priv/static/assets/css", __DIR__)]
       ]}
  ]

config :volt, :server,
  prefix: "/assets",
  watch_dirs: [Path.expand("../apps/ex_storage_service_web/lib/", __DIR__)]

config :volt, sourcemap: :linked
```

## Why DuskMoon elements need pre-bundling

`@duskmoon-dev/elements` are custom elements (e.g. `<el-dm-button>`) whose
`register.js` self-registers via `customElements.define()`. Volt's vendor prebundler
**cannot** bundle them in an umbrella: OXC sets the bundle cwd to the package's parent
directory, which blocks resolving sibling scoped packages (`@duskmoon-dev/el-base`,
`@duskmoon-dev/core`, …).

The workaround is a Mix task that calls OXC directly with the **project root** as cwd,
then writes the bundled output to `assets/js/duskmoon_elements.js` — a plain source file
Volt serves normally. `app.js` then just imports that file.

## The `mix duskmoon.bundle` task

Place this at `apps/<web_app>/lib/mix/tasks/duskmoon.bundle.ex`. It builds a virtual
entry that imports each element's `register`, bundles with OXC from the project root, and
writes a single `duskmoon_elements.js`.

```elixir
defmodule Mix.Tasks.Duskmoon.Bundle do
  @moduledoc """
  Pre-bundle @duskmoon-dev/elements for Volt dev server.

  Volt's vendor prebundler cannot bundle @duskmoon-dev elements in umbrella
  projects because OXC sets the bundle cwd to the package's parent directory,
  which prevents resolving sibling scoped packages (@duskmoon-dev/el-base,
  @duskmoon-dev/core, etc.).

  This task uses OXC directly with the project root as cwd, then writes the
  bundled output to assets/js/ where Volt can serve it as a regular source file.

  ## Usage

      mix duskmoon.bundle                    # Bundle all elements
      mix duskmoon.bundle el-button el-table # Bundle specific elements
  """

  use Mix.Task

  @shortdoc "Pre-bundle @duskmoon-dev/elements for Volt"

  # Elements with dynamic imports (el-markdown, el-code-engine, el-markdown-input,
  # el-chat) are excluded — OXC cannot bundle them into a single file.
  @all_elements ~w(
    el-accordion el-alert el-autocomplete el-badge el-bottom-navigation
    el-bottom-sheet el-breadcrumbs el-button el-card el-cascader el-chart
    el-chip el-circle-menu el-code-block el-datepicker el-dialog
    el-drawer el-file-upload el-form el-form-group el-input
    el-menu el-navbar el-navigation el-nested-menu el-otp-input el-pagination
    el-pin-input el-popover el-progress el-segment-control el-select el-slider
    el-stepper el-switch el-table el-tabs el-theme-controller el-time-input
    el-tooltip
  )

  @impl Mix.Task
  def run(args) do
    elements = if args == [], do: @all_elements, else: args
    %{node_modules: node_modules_path, output: output_path} = paths()

    Mix.shell().info("Bundling #{length(elements)} @duskmoon-dev element(s)...")

    imports =
      Enum.map_join(elements, "\n", fn el ->
        "import '@duskmoon-dev/#{el}/register';"
      end)

    # OXC requires the entry file to live inside cwd
    tmp_dir = Path.join(File.cwd!(), "_build/duskmoon_bundle")
    File.mkdir_p!(tmp_dir)
    entry = Path.join(tmp_dir, "entry.js")
    File.write!(entry, imports)

    case OXC.bundle(entry,
           cwd: File.cwd!(),
           format: :esm,
           modules: [node_modules_path],
           define: %{"process.env.NODE_ENV" => ~s("development")},
           exports: :named,
           preserve_entry_signatures: :strict
         ) do
      {:ok, %{code: code}} -> write_output(output_path, code, elements)
      {:ok, code} when is_binary(code) -> write_output(output_path, code, elements)
      {:error, errors} -> Mix.raise("Failed to bundle elements: #{inspect(errors)}")
    end
  after
    File.rm_rf(Path.join(File.cwd!(), "_build/duskmoon_bundle"))
  end

  defp paths do
    cwd = File.cwd!()

    if String.ends_with?(cwd, "apps/ex_storage_service_web") do
      root = Path.expand("../..", cwd)

      %{
        node_modules: Path.join(root, "node_modules"),
        output: Path.join(cwd, "assets/js/duskmoon_elements.js")
      }
    else
      %{
        node_modules: Path.join(cwd, "node_modules"),
        output: Path.join([cwd, "apps/ex_storage_service_web", "assets/js/duskmoon_elements.js"])
      }
    end
  end

  defp write_output(output_path, code, elements) do
    header = """
    /**
     * Pre-bundled @duskmoon-dev/elements (generated by mix duskmoon.bundle)
     *
     * Elements: #{Enum.join(elements, ", ")}
     *
     * DO NOT EDIT — regenerate with: mix duskmoon.bundle #{Enum.join(elements, " ")}
     */
    """

    File.mkdir_p!(Path.dirname(output_path))
    File.write!(output_path, header <> code)
    size_kb = (byte_size(code) / 1024) |> Float.round(1)
    Mix.shell().info("Wrote #{output_path} (#{size_kb} KB, #{length(elements)} element(s))")
  end
end
```

Adapt the `paths/0` directory checks and the hardcoded `ex_storage_service_web` name to
the target project.

## Wire the bundle step into aliases

`duskmoon.bundle` must run during setup (after npm install) and before each deploy build:

```elixir
defp aliases do
  [
    setup: ["deps.get", "assets.setup", "assets.build"],
    "assets.setup": ["cmd --app ex_storage_service_web mix npm.install", "duskmoon.bundle"],
    "assets.build": ["volt.build --tailwind"],
    "assets.deploy": ["duskmoon.bundle", "volt.build --tailwind", "phx.digest"]
  ]
end
```

## `app.js` importing the pre-bundled elements

```js
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

// @duskmoon-dev/elements — pre-bundled by `mix duskmoon.bundle`
import "./duskmoon_elements.js";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
});

liveSocket.connect();
window.liveSocket = liveSocket;
```

## `app.css` with DuskMoon (Tailwind v4, CSS-first)

`@duskmoon-dev/core` is added to `package.json` and pulled in as a Tailwind plugin plus
direct CSS imports. No `tailwind.config.js`:

```css
@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
/* WORKAROUND(upstream): duskmoon-dev/phoenix-duskmoon-ui#30 */
/* Use direct CSS imports until phoenix_duskmoon/components is exported. */
@import "@duskmoon-dev/core/themes/sunshine";
@import "@duskmoon-dev/core/themes/moonlight";
@import "@duskmoon-dev/core/components";
@import "../../../../deps/phoenix_duskmoon/assets/css/element-theme-bridge.css";
@source "../../lib/ex_storage_service_web.ex";
@source "../../lib/ex_storage_service_web/**/*.ex";
@source "../../lib/ex_storage_service_web/**/*.heex";
@source "../js/**/*.js";
/* Scan the phoenix_duskmoon dep so its component classes aren't purged */
@source "../../../../deps/phoenix_duskmoon/**/*.{ex,heex}";
```

Corresponding `assets/package.json`:

```json
{
  "name": "my_app_assets",
  "private": true,
  "type": "module",
  "dependencies": {
    "@duskmoon-dev/core": "1.17.0"
  }
}
```
