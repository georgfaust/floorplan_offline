defmodule FptoolWeb.Icons do
  use Phoenix.Component

  attr(:type, :string, required: true)
  attr(:index, :any, default: nil)
  attr(:label, :string, default: nil)
  attr(:data, :any, default: nil)

  def icon(%{type: "device"} = assigns), do: ~H"<.device {@data} />"

  def icon(assigns) do
    ~H"""
    <%= case @type do %>
      <% "light" -> %>
        <.light />
      <% "button" -> %>
        <.button led={false} />
      <% "button-led" -> %>
        <.button led={true} />
      <% "ssd" -> %>
        <.ssd />
      <% "motor" -> %>
        <.motor />
      <% "arrow-up" -> %>
        <div class="w-full h-full border border-red-500 grid">
          <.arrow direction={:up} />
        </div>
      <% "arrow-down" -> %>
        <div class="w-full h-full border border-red-500 grid">
          <.arrow direction={:down} />
        </div>
      <% "reserve" -> %>
        <div class="w-full h-full border border-zinc-400 grid">
          <div class="place-self-center text-xs text-zinc-500 -mb-px">RES</div>
        </div>
      <% box_icon -> %>
        <div class="w-full h-full border border-red-400 grid bg-white">
          <div class="place-self-center text-xs text-red-500 -mb-px">
            <%= box_icon %>
          </div>
        </div>
    <% end %>
    """
  end

  defp arrow(assigns) do
    assigns =
      assign_new(assigns, :rotate_angle, fn -> if assigns.direction == :down, do: 180, else: 0 end)

    ~H"""
    <svg
      viewBox="0 0 100 100"
      xmlns="http://www.w3.org/2000/svg"
      class="stroke-red-500"
      style="fill-opacity: 0.7"
    >
      <g transform={"rotate(#{@rotate_angle} 50 50)"}>
        <rect x="0" y="0" width="100" height="100" stroke="none" fill="white" data-background />
        <line
          vector-effect="non-scaling-stroke"
          x1="50"
          y1="0"
          x2="50"
          y2="100"
          stroke-width="1px"
          stroke-linecap="round"
        />
        <line
          vector-effect="non-scaling-stroke"
          x1="50"
          y1="0"
          x2="0"
          y2="50"
          stroke-width="1px"
          stroke-linecap="round"
        />
        <line
          vector-effect="non-scaling-stroke"
          x1="50"
          y1="0"
          x2="100"
          y2="50"
          stroke-width="1px"
          stroke-linecap="round"
        />
      </g>
    </svg>
    """
  end

  defp motor(assigns) do
    ~H"""
    <svg
      viewBox="0 0 100 100"
      xmlns="http://www.w3.org/2000/svg"
      class="stroke-blue-500 stroke-1"
      style="fill-opacity: 0.7"
    >
      <circle vector-effect="non-scaling-stroke" cx="50" cy="50" r="48" fill="white" data-background />
      <text
        text-anchor="middle"
        dominant-baseline="middle"
        font-size="60px"
        x="50"
        y="55"
        stroke="none"
        class="fill-blue-500/100"
        style="fill-opacity: 1.0"
      >
        M
      </text>
    </svg>
    """
  end

  defp button(assigns) do
    ~H"""
    <svg
      viewBox="0 0 100 100"
      xmlns="http://www.w3.org/2000/svg"
      class="stroke-green-500 stroke-1"
      style="fill-opacity: 0.7"
    >
      <circle vector-effect="non-scaling-stroke" cx="50" cy="50" r="48" fill="white" data-background />
      <circle vector-effect="non-scaling-stroke" cx="50" cy="50" r="34" fill="white" data-background />
      <%= if @led  do %>
        <g>
          <line
            vector-effect="non-scaling-stroke"
            x1="26"
            y1="74"
            x2="74"
            y2="26"
            stroke-linecap="round"
            fill="none"
          />
          <line
            vector-effect="non-scaling-stroke"
            x1="26"
            y2="74"
            x2="74"
            y1="26"
            stroke-linecap="round"
            fill="none"
          />
        </g>
      <% end %>
    </svg>
    """
  end

  defp light(assigns) do
    ~H"""
    <svg
      viewBox="0 0 100 100"
      xmlns="http://www.w3.org/2000/svg"
      class="stroke-red-500 stroke-1"
      style="fill-opacity: 0.7"
    >
      <rect x="0" y="0" width="100" height="100" stroke="none" fill="white" data-background />
      <path d="M0,0 L100,100 M100,0 L0,100" vector-effect="non-scaling-stroke" fill="none" />
    </svg>
    """
  end

  attr(:rotate_angle, :integer, default: 90)
  attr(:count, :integer, default: 2)

  defp ssd(assigns) do
    ~H"""
    <svg
      viewBox="0 0 100 100"
      xmlns="http://www.w3.org/2000/svg"
      class="stroke-blue-500"
      style="fill-opacity: 0.7"
    >
      <g transform={"rotate(#{@rotate_angle} 50 50)"}>
        <rect x="0" y="0" width="100" height="100" stroke="none" fill="white" data-background />
        <%= if @count != 1 do %>
          <line
            vector-effect="non-scaling-stroke"
            x1="60"
            y1="0"
            x2="80"
            y2="30"
            stroke-width="1px"
            stroke-linecap="round"
          />
          <text
            transform="rotate(90 80 50)"
            x="80"
            y="50"
            dominant-baseline="middle"
            text-anchor="middle"
            stroke-width="0"
            class="fill-green-500/100 text-[30pt] font-normal select-none"
            style="fill-opacity: 1.0"
          >
            <%= @count %>
          </text>
        <% end %>
        <line
          vector-effect="non-scaling-stroke"
          x1="50"
          y1="0"
          x2="50"
          y2="100"
          stroke-width="1px"
          stroke-linecap="round"
          fill="none"
        />
        <line
          vector-effect="non-scaling-stroke"
          x1="0"
          y1="50"
          x2="50"
          y2="50"
          stroke-width="1px"
          stroke-linecap="round"
          fill="none"
        />
        <circle
          vector-effect="non-scaling-stroke"
          cx="100"
          cy="50"
          r="48"
          stroke-width="1px"
          fill="none"
        />
      </g>
    </svg>
    """
  end

  attr :max_device_channels, :integer, default: nil
  attr :ia, :string, default: nil

  defp device(assigns) do
    ~H"""
    <div
      class={[
        "relative box-content w-10 h-10 border border-red-500 border-t-8",
        @type == "LC" && "border-b-8",
        @type == "PSU" && "border-b-8 border-b-gray-700"
      ]}
      data-device-icon
    >
      <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg" class="stroke-red-500">
        <line x1="0" y1="100" x2="100" y2="0" stroke-width="2px" />
      </svg>
      <div class="absolute top-0 left-0 text-sm p-0.5 leading-none">
        <%= @max_device_channels %>
      </div>
      <div class="absolute bottom-0 right-0 text-sm px-0.5 leading-none">
        <%= @type %>
      </div>
      <div
        class="absolute top-0 left-full leading-none text-xs text-green-700"
        style="writing-mode: vertical-lr"
      >
        <%= @ia %>
      </div>
    </div>
    """
  end
end
