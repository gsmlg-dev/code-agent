# Data Transfer Between Phoenix and React

Four channels cross the seam. Pick per use case; they compose freely. All of them
use only the standard LiveView JS hook API (`this.el`, `this.pushEvent`,
`this.handleEvent`) — nothing extra to install.

## 1. Phoenix → React: initial data (at mount)

Pass values the server already knows as `data-*` attributes on the placeholder
node. Encode anything beyond a short string with `Jason.encode!/1`.

LiveView:

```heex
<div
  id={@id}
  phx-update="ignore"
  phx-hook="MountClip"
  data-token={@token}
  data-props={Jason.encode!(%{user_id: @user_id, rows: @rows})}
>
</div>
```

Hook:

```js
mounted() {
  this.root = createRoot(this.el);
  this.props = JSON.parse(this.el.dataset.props || '{}'); // { user_id, rows }
  this.token = this.el.dataset.token;
  this.render();
}
```

Rules:
- `dataset.props` reads the `data-props` attribute (camelCase conversion:
  `data-user-id` → `dataset.userId`).
- Always `JSON.parse` structured data; attributes are strings.
- This is a **one-time** snapshot for the first render. With `phx-update="ignore"`
  the node is frozen afterward, so don't rely on attribute changes for updates —
  use channel 2.

## 2. Phoenix → React: live updates (after mount)

Because `phx-update="ignore"` stops LiveView from patching the node, ongoing
updates flow as **events**, not DOM changes. The server pushes an event; the hook
receives it and re-renders the React tree with new props (React reconciles).

LiveView:

```elixir
def handle_info({:new_data, payload}, socket) do
  {:noreply, push_event(socket, "clip:update", payload)}
end
```

Hook:

```js
mounted() {
  // ...initial render...
  this.handleEvent('clip:update', (payload) => {
    this.props = { ...this.props, ...payload };
    this.render();           // re-render the same root with merged props
  });
}
```

Notes:
- `push_event/3` targets events to the hook(s) on the page; the hook's
  `handleEvent` callback fires with the decoded payload.
- Re-rendering the existing root is the simplest update strategy — React diffs and
  patches only what changed. (Alternatively, expose a state setter from the
  component via a ref and call it; re-rendering is usually simpler.)
- You don't need to remove `handleEvent` listeners manually; they go away when the
  hook is destroyed.

## 3. React → Phoenix: events (server-owned actions)

Hand the component a function that calls `this.pushEvent`. The event lands in the
LiveView's `handle_event/3`. An optional third callback receives the server's
reply.

Hook bridge:

```js
bridge() {
  return {
    pushEvent: (event, payload, onReply) => this.pushEvent(event, payload, onReply),
  };
}
```

Component:

```jsx
bridge.pushEvent('save', { id, name }, (reply) => {
  // reply is whatever handle_event returns via {:reply, map, socket}
  if (reply.ok) { /* ... */ }
});
```

LiveView:

```elixir
def handle_event("save", %{"id" => id, "name" => name}, socket) do
  # ...do the work...
  {:reply, %{ok: true}, socket}      # or {:noreply, socket}
end
```

Use this for anything the server must own: persistence, authorization-sensitive
actions, or work that should update other parts of the LiveView.

## 4. React → Phoenix: navigation

To navigate the host app from inside React, send an event to the server and let
the LiveView drive navigation with the public `push_navigate/2` (or `push_patch/2`
to stay on the same LiveView). This keeps you on documented API rather than
reaching into LiveView's internal JS (`liveSocket.historyRedirect`).

Hook bridge:

```js
navigate: (path) => this.pushEvent('navigate', { to: path })
```

LiveView:

```elixir
def handle_event("navigate", %{"to" => to}, socket) do
  {:noreply, push_navigate(socket, to: to)}   # or push_patch(socket, to: to)
end
```

Component:

```jsx
bridge.navigate(`/things/${id}`);
```

## Passing the bridge to the component: prop vs context

Two equivalent styles — choose one and stay consistent:

- **Prop:** `this.root.render(<YourComponent {...props} bridge={this.bridge()} />)`.
  Simple, explicit, easy to test.
- **Context:** wrap in a provider the component reads via a hook
  (`useBridge()`), so deeply-nested children get `pushEvent`/`navigate`/`token`
  without prop-drilling. See `assets/react/bridge-context.js`.

## Quick checklist

- `phx-update="ignore"` on the placeholder — always.
- `this.root` set before any `await` in `mounted()`; `this.root.unmount()` in
  `destroyed()`.
- Initial data via `data-*` (+ `Jason.encode!`/`JSON.parse`); live updates via
  `push_event` + `handleEvent`.
- React→server via `pushEvent` (with optional reply); navigation via a
  `"navigate"` event + server `push_navigate/2`.
