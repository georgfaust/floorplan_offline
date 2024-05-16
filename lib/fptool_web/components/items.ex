defmodule FptoolWeb.Items do
  use Phoenix.Component

  @item_width 50
  @transform_default %{"rotate" => 0, "scale" => 1}

  attr :transform, :map, default: %{}
  attr :selected_item, :string
  attr :items, :map

  def item(assigns) do
    assigns =
      assigns
      |> assign(:item_width, @item_width)
      |> assign(:transform, Map.merge(@transform_default, assigns.transform))

    ~H"""
    <div
      id={@id}
      phx-hook="ItemHook"
      data-is-selected={@id == @selected_item && "selected"}
      data-anchor-x={@x}
      data-anchor-y={@y}
      data-item-type={@type}
      data-transform={Jason.encode!(@transform)}
      class="absolute origin-top p-[5px]"
      style={"width: #{@item_width}px; left: #{@x}px; top: #{@y}px; transform: #{render_transform(@transform)};"}
    >
      <.item_inner {assigns} />
    </div>
    """
  end

  defp item_inner(%{type: "frame"} = assigns) do
    ~H"""
    <!-- NOTE: flex used here to make the relative child ignore the fixed width of the parent -->
    <div class="flex">
      <div class="relative top-0 left-0 flex flex-col gap-1 max-w-min">
        <%= for {slot, slot_index} <- Enum.with_index(@slots) do %>
          <.frame_slot
            {slot}
            slot_index={slot_index}
            rotate={@transform["rotate"]}
            frame_id={@id}
            items={@items}
          />
        <% end %>
      </div>
    </div>
    """
  end

  defp item_inner(assigns) do
    ~H"""
    <FptoolWeb.Icons.icon type={@type} />
    <div class="absolute left-full top-0 h-full w-min flex items-center justify-center">
      <div class="p-1 text-neutral-600 text-sm">
        <%= @label %>
      </div>
    </div>
    """
  end

  defp frame_slot(assigns) do
    back_rotate? = assigns.rotate > 90 and assigns.rotate < 270
    label = Enum.map_join(assigns.targets, ", ", &assigns.items[&1].label)

    assigns =
      assigns
      |> assign(:back_rotate, if(back_rotate?, do: "180deg", else: "0deg"))
      |> assign(:label, label)

    ~H"""
    <div class="flex h-[50px]">
      <div
        id={"button_#{@frame_id}_#{@slot_index}"}
        data-button-targets={"#{inspect(@targets)}"}
        class="w-[50px] h-[50px]"
      >
        <FptoolWeb.Icons.icon type="button" />
      </div>
      <div class="px-1 flex items-center justify-center">
        <span
          class="origin-center whitespace-nowrap text-neutral-600 text-sm"
          style={"transform: rotate(#{@back_rotate})"}
        >
          <%= @label %>
        </span>
      </div>
    </div>
    """
  end

  @unit %{"rotate" => "deg"}
  defp render_transform(transform) do
    Enum.map_join(transform, " ", fn {k, v} -> "#{k}(#{v}#{@unit[k]})" end)
  end
end
