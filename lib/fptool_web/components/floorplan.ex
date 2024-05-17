defmodule FptoolWeb.Floorplan do
  use Phoenix.Component

  alias Vector, as: V

  attr :selected_room, :string, default: nil
  attr :viewbox, :string, required: true
  attr :walls, :list, required: true
  attr :rooms, :list, default: []

  def floorplan(assigns) do
    ~H"""
    <svg
      id="svg-canvas"
      viewBox={@viewbox}
      preserveAspectRatio="none"
      class="relative top-0 left-0 w-full"
    >
      <defs>
        <filter x="0" y="0" width="1" height="1" id="svg-text-background">
          <feFlood flood-color="rgb(245 245 245)" result="bg" />
          <feMerge>
            <feMergeNode in="bg" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      <g id="rooms">
        <%= for room <- @rooms do %>
          <.room room={room} walls={@walls} selected_room={@selected_room} />
        <% end %>
      </g>
      <g id="walls">
        <%= for wall <- @walls do %>
          <.wall {wall} />
        <% end %>
      </g>
    </svg>
    """
  end

  def room(assigns) do
    corners = assigns.room.corners

    polygon =
      Enum.map_join(corners, " ", fn corner ->
        %{x: x, y: y} = corner
        "#{x} #{y}"
      end)

    walls =
      corners
      |> Enum.chunk_every(2, 1, [hd(corners)])
      |> Enum.map(fn [p1, p2] -> %{p1: p1, p2: p2} end)

    assigns = assigns |> assign(:polygon, polygon) |> assign(:walls, walls)

    ~H"""
    <g>
      <polygon
        id={@room.id}
        points={@polygon}
        data-element-type="room"
        data-walls={Jason.encode!(@walls)}
        phx-click="select-room"
        phx-value-id={@room.id}
        class={[
          "hover:fill-blue-200/25",
          @room.id == @selected_room && "fill-blue-200/50",
          @room.id != @selected_room && "fill-white/0"
        ]}
        stroke="none"
      />
      <text
        text-anchor="middle"
        dominant-baseline="middle"
        font-size="50mm"
        x={@room.centroid.x}
        y={@room.centroid.y}
        stroke="none"
        class="fill-blue-400/75"
        style="fill-opacity: 1.0"
      >
        <tspan x={@room.centroid.x} dy="0"><%= @room.name %></tspan>
      </text>
    </g>
    """
  end

  attr :doors, :list, default: []
  attr :windows, :list, default: []

  def wall(assigns) do
    ~H"""
    <line
      id={"id_#{@id}"}
      data-element-type="wall"
      data-angle={@angle}
      data-thickness={@width}
      x1={@from.x}
      y1={@from.y}
      x2={@to.x}
      y2={@to.y}
      style="stroke: gray;"
      stroke-linecap="square"
      stroke-opacity="100%"
      class="hover:stroke-blue-300"
      stroke-width={@width}
    />
    <%= for window <- @windows do %>
      <.window {window} wall={assigns} />
    <% end %>
    <%= for door <- @doors do %>
      <.door {door} wall={assigns} />
    <% end %>
    """
  end

  def window(assigns) do
    start_p = get_start_point(assigns.offset, assigns.wall)
    assigns = assigns |> assign(:start_p, start_p)

    ~H"""
    <g
      transform={"translate(#{@start_p.x}, #{@start_p.y}) rotate(#{@wall.angle})"}
      class="group"
      vector-effect="non-scaling-stroke"
    >
      <!-- hole in wall -->
      <path
        id={"id_#{@id}"}
        data-element-type="window"
        data-wall-ref={@wall.id}
        data-offset={@offset}
        data-width={@width}
        d={"M0,0 l#{@width},0"}
        stroke-width={@wall.width - 16}
        class="group-hover:stroke-blue-200"
        style="stroke: white;"
      />
      <!-- pane -->
      <path d={"M0,0 l#{@width},0"} stroke-width="4" stroke="black" />
      <!-- frame left -->
      <path d="M0,0 l50,0" stroke-width={@wall.width - 4} stroke="black" />
      <!-- frame right -->
      <path d={"M#{@width-50},0 l50,0"} stroke-width={@wall.width - 4} stroke="black" />
    </g>
    """
  end

  attr :flip, :boolean, default: false
  attr :din_direction, :string, default: "left"
  attr :wall, :any

  def door(assigns) do
    start_p = get_start_point(assigns.offset, assigns.wall)

    transform =
      case {assigns.din_direction, assigns.flip} do
        {"right", false} -> ""
        {"right", true} -> "scale(-1, -1) translate(-#{assigns.width}, 0)"
        {"left", false} -> "scale(-1, 1) translate(-#{assigns.width}, 0)"
        {"left", true} -> "scale(1, -1)"
      end

    assigns =
      assigns
      |> assign(:transform, transform)
      |> assign(:start_p, start_p)

    ~H"""
    <g
      transform={"translate(#{@start_p.x}, #{@start_p.y})"}
      class="group fill-white/0 hover:fill-blue-200/50"
      vector-effect="non-scaling-stroke"
    >
      <g transform={"rotate(#{@wall.angle}) #{@transform}"}>
        <path
          d={"M0,0 A#{@width},#{@width} 0 0 1 #{@width},-#{@width} l0,#{@width}"}
          stroke-width="8"
          stroke-dasharray="20"
          class="stroke-neutral-600"
        />
        <path
          id={"id_#{@id}"}
          data-element-type="door"
          data-wall-ref={@wall.id}
          data-offset={@offset}
          data-width={@width}
          d={"M0,0 l#{@width},0"}
          stroke-width={@wall.width - 16}
          class="group-hover:stroke-blue-200"
          style="stroke: white;"
        />
      </g>
    </g>
    """
  end

  # --- helpers
  defp get_start_point(offset, wall) do
    wall.direction |> V.s_mul(offset) |> V.add(wall.from)
  end
end
