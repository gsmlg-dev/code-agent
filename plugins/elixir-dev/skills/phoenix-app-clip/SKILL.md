---
name: phoenix-app-clip
description: >-
  Use when mounting a React element into a Phoenix LiveView DOM node and moving
  data between the two — the "app-clip" integration pattern. Trigger this
  whenever the user wants to render a React component (or any client-side
  element) from inside a LiveView, embed an SPA-style widget in a LiveView page,
  use `createRoot`/`ReactDOM` inside a `phx-hook`, pass server data from Phoenix
  into a React tree, push events or state from React back to a LiveView's
  `handle_event/3`, share an auth token or trigger navigation from a mounted
  React component, or mentions app-clips, `phx-hook` `Mount*`, `phx-update`
  `"ignore"`, `pushEvent`/`handleEvent`, or React-in-LiveView integration. Use it
  even if they only say "render my React component in a LiveView" or "get data
  from Phoenix into React". This skill covers ONLY the integration seam —
  mounting and bidirectional data transfer. What the React component is, and
  which UI libraries it uses, is the user's own concern.
---

# Mounting React in Phoenix LiveView + transferring data

This skill covers one thing: the **seam** between a Phoenix LiveView and a React
element mounted inside it. Two mechanics:

1. **Mounting** — a LiveView renders an empty node; a JS hook mounts a React root
   into it and tears it down cleanly.
2. **Data transfer** — moving values from Phoenix into React, and events/state
   from React back to Phoenix.

What the React component *is* — its UI library, its internal state, its styling —
is entirely the user's concern. This skill never prescribes that. It only wires
the component into LiveView and the two data channels.

## The placeholder node

The LiveView renders an empty node and hands it to a hook. Two attributes matter:

```heex
<div
  id={@id}
  phx-update="ignore"
  phx-hook="MountClip"
  data-props={Jason.encode!(@initial)}
>
</div>
```

- **`phx-hook="MountClip"`** names the JS hook that will mount React here.
- **`phx-update="ignore"` is mandatory.** Once React owns this subtree, LiveView
  must not patch it, or React's DOM and LiveView's DOM diffing fight and the UI
  corrupts. `ignore` tells LiveView to leave the node's children alone after the
  first render. (Consequence: you can't stream live updates by changing the
  node's contents — use the event channel below.)
- **`data-*` attributes** carry the *initial* data from Phoenix into the hook.
  Encode anything non-trivial with `Jason.encode!/1` and parse it in JS.

## Mounting — the JS hook

The hook creates a React root on `this.el`, renders the user's component, and
**unmounts on `destroyed()`** (LiveView navigations call `destroyed()`; skipping
unmount leaks a root and its listeners every time).

```js
import * as React from 'react';
import { createRoot } from 'react-dom/client';
import { YourComponent } from '@your-scope/your-package';

export const MountClip = {
  MountClip: {
    mounted() {
      this.root = createRoot(this.el);     // store before any async work
      this.props = JSON.parse(this.el.dataset.props || '{}');
      this.render();
    },
    destroyed() {
      this.root?.unmount();                // mandatory
    },
    render() {
      this.root.render(<YourComponent {...this.props} bridge={this.bridge()} />);
    },
  },
};
```

`mounted()` may `await import(...)` the component for code-splitting — just set
`this.root` before the await so `destroyed()` can find it.

## Data transfer — the four channels

| Direction | When | Mechanism |
|-----------|------|-----------|
| Phoenix → React | initial values at mount | `data-*` attribute on the node → read `this.el.dataset.*` in `mounted()` → pass as props |
| Phoenix → React | live updates after mount | LiveView `push_event/3` → hook `this.handleEvent("name", fn)` → re-render React with new props |
| React → Phoenix | a user action the server owns | a `pushEvent` function handed to React (calls `this.pushEvent`) → LiveView `handle_event/3` (optional reply callback) |
| React → Phoenix | navigation | a `navigate` function handed to React → `this.pushEvent("navigate", ...)` → LiveView `push_navigate/2` |

You hand the two React→Phoenix functions (and the token, etc.) to the component
through a small **bridge** object — either as a prop (as above) or via a React
context the component reads. Both are shown in the templates.

```js
// inside the hook
bridge() {
  return {
    token: this.el.dataset.token,
    pushEvent: (event, payload, onReply) => this.pushEvent(event, payload, onReply),
    // navigation goes through the server's public push_navigate/2
    navigate: (path) => this.pushEvent('navigate', { to: path }),
  };
}

// live updates: server push_event('clip:update', payload) → re-render
mounted() {
  // ...
  this.handleEvent('clip:update', (payload) => {
    this.props = { ...this.props, ...payload };
    this.render();
  });
}
```

`this.el`, `this.pushEvent`, `this.handleEvent` are all the standard LiveView JS
hook API — no extra packages are required.

See `references/data-transfer.md` for each channel in full, including reply
callbacks, JSON-encoding rules, and why live updates must go through events rather
than attribute changes.

## Workflow

State two identifiers: `name` (slug/dir) and `Name` (PascalCase). Then:

1. **Have a React component** exporting something the hook can render. (This is
   your code — the skill doesn't dictate it. It just needs to accept props and,
   if it talks back to the server, use the `bridge`.)
2. **Write the hook** `assets/js/clips/<name>.js` exporting `Mount<Name>` — copy
   `assets/phoenix/clip_hook.js`. Wire the bridge and any `handleEvent`s.
3. **Register it** in `assets/js/hooks.js` and pass `hooks` to your `LiveSocket`.
4. **Render the placeholder** from a LiveView / LiveComponent with
   `phx-hook="Mount<Name>"`, `phx-update="ignore"`, and `data-*` for initial
   data — copy `assets/phoenix/live.ex`, `live_component.ex`, `index.html.heex`.
5. **Add the route** in `router.ex`.
6. **Build & verify:** build the JS bundle, open the route, confirm the node is
   replaced by your component, that initial `data-*` arrived as props, and that a
   `pushEvent` from React lands in `handle_event/3`.

## Templates

Phoenix side (copy into your app):
- `assets/phoenix/clip_hook.js` — the mount + bidirectional bridge hook (the core
  of this skill); goes in `assets/js/clips/`.
- `assets/phoenix/live.ex`, `live_component.ex`, `index.html.heex` — the
  placeholder node and its LiveView shell, showing `data-*` initial data,
  `push_event` live updates, and `handle_event` for events from React.

React side (illustrative — your component is your own):
- `assets/react/example_component.jsx` — a minimal, library-free stub showing how
  a component consumes props + the bridge. **Replace it with your own component.**
- `assets/react/bridge-context.js` — optional context so nested components read
  `token`/`pushEvent`/`navigate` via `useBridge()` instead of a prop.

Replace `__name__` / `__Name__` / `__TITLE__` / `@your-scope` placeholders
(legend at the top of each file).
