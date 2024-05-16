defmodule FptoolWeb.DemoLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    nothing to see here.
    """
  end

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
    }
  end
end
