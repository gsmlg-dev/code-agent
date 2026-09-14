# LiveComponent rendering the placeholder node the hook mounts into.
# Place at lib/<app>_web/live/__name___live/__name__.ex
# phx-hook MUST match the key from clips/__name__.js (Mount__Name__).
# phx-update="ignore" is required so LiveView never patches the React-owned DOM.
# data-* attributes carry the INITIAL data into the hook (JSON for structured data).
defmodule <App>Web.__Name__Live.LiveComponent.__Name__ do
  use <App>Web, :live_component

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      phx-update="ignore"
      phx-hook="Mount__Name__"
      data-token={@token}
      data-props={Jason.encode!(@initial)}
    >
    </div>
    """
  end

  def mount(socket), do: {:ok, socket}

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:id, assigns.id)
     |> assign(:initial, assigns[:initial] || %{})
     |> assign(:token, assigns[:token])}
  end
end
