defmodule FptoolWeb.Toolbar do
  use Phoenix.Component

  alias FptoolWeb.Icons

  def toolbar(assigns) do
    ~H"""
    <div class="z-50 m-6 p-4 select-none bg-cyan-200 fixed">
      <div class="flex flex-col gap-6">
        <div id="sidebar" class="relative flex flex-col gap-y-[10px]">
          <.item type="ssd" />
          <.item type="light" />
          <.item type="frame" />
          <.item type="motor" />
        </div>
      </div>
    </div>
    """
  end

  def item(assigns) do
    icon_type = if assigns.type == "frame", do: "button", else: assigns.type
    assigns = assign(assigns, :icon_type, icon_type)

    ~H"""
    <div
      data-clone="do-clone"
      data-item-type={@type}
      id={"toolbar-item-#{@type}"}
      phx-hook="ItemHook"
      data-transform="{}"
      class="z-50 draggable relative top-0 w-[50px] h-[50px] origin-top"
    >
      <Icons.icon type={@icon_type} />
    </div>
    """
  end
end
