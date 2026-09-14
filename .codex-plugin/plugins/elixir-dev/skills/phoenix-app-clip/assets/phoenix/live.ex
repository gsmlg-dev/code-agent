# LiveView (route target / shell). Place at lib/<app>_web/live/__name___live/index.ex
# Replace: <App> PascalCase app web base; __Name__ PascalCase; __TITLE__ page title.
# Compute the initial data you want to hand to React and assign it; the template
# encodes it onto the placeholder node.
defmodule <App>Web.__Name__Live.Index do
  use <App>Web, :live_view

  @impl true
  def mount(_params, session, socket) do
    # token: wherever your app keeps it (session, connect params, etc.)
    token = session["token"]

    {:ok,
     assign(socket,
       page_title: "__TITLE__",
       token: token,
       initial: %{title: "__TITLE__", count: 0}
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: socket

  # React -> Phoenix: events the mounted component sends via bridge.pushEvent.
  @impl true
  def handle_event("increment", %{"by" => by}, socket) do
    count = socket.assigns.initial.count + by
    socket = assign(socket, :initial, %{socket.assigns.initial | count: count})
    # Phoenix -> React (live update): push new state back into the mounted tree.
    {:noreply, push_event(socket, "clip:update", %{count: count})}
  end

  def handle_event("save", _payload, socket) do
    # reply is delivered to the pushEvent callback in React
    {:reply, %{ok: true}, socket}
  end

  # React -> Phoenix: navigation. bridge.navigate(path) sends this; the server
  # drives navigation via the public push_navigate/2 (use push_patch/2 to stay
  # on the same LiveView).
  def handle_event("navigate", %{"to" => to}, socket) do
    {:noreply, push_navigate(socket, to: to)}
  end
end
