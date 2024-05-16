defmodule FpFromRevitTest do
  use ExUnit.Case

  def load_element(element, wall_index) do
    wall = wall_index[element.host]
    location = Map.take(element.location, [:x, :y])
    facing_angle = VectorM.angle(element.facing.orientation, VectorM.right())

    bbox_v = VectorM.from_points(element.bbox.min, element.bbox.max)
    rotated_to_x_axis_bbox_v = VectorM.rotate(bbox_v, -facing_angle - 90)
    width = abs(rotated_to_x_axis_bbox_v.x)
    offset = VectorM.distance(wall.from, location) - width / 2

    %{
      id: element.id,
      host: element.host,
      offset: offset,
      width: width
    }
  end

  @tag :revit
  test "floorplan from revit" do
    fp = File.read!("priv/floorplan_revit_schema.json") |> Jason.decode!(keys: :atoms)

    for floor <- fp do
      walls =
        for wall <- floor.walls do
          from = Map.take(wall.line.start, [:x, :y])
          to = Map.take(wall.line[:end], [:x, :y])
          direction_v_m = VectorM.from_points(from, to) |> VectorM.normalize()
          angle = VectorM.right() |> VectorM.angle(direction_v_m)

          %{
            from: from,
            to: to,
            id: wall.id,
            width: wall.width,
            angle: angle,
            direction_v_m: direction_v_m,
            normal: VectorM.normal(direction_v_m)
          }
        end

      wall_index = walls |> Map.new(&{&1.id, &1})

      doors =
        for door <- floor.doors do
          # TODO
          # - there are other props/params to consider, esp (Hand)Facing
          # - code for left-right seems to be wrong, as here left==right!?
          din_direction =
            if door.symbol_operation == "SINGLE_SWING_LEFT" do
              "right"
            else
              "left"
            end

          Map.merge(
            load_element(door, wall_index),
            %{
              din_direction: din_direction,
              flip: !door.facing.flipped
            }
          )
        end

      windows =
        for window <- floor.windows do
          load_element(window, wall_index)
        end

      windows_by_host = Enum.group_by(windows, & &1.host)
      doors_by_host = Enum.group_by(doors, & &1.host)

      walls =
        for wall <- walls do
          Map.merge(
            wall,
            %{
              doors: Map.get(doors_by_host, wall.id, []),
              windows: Map.get(windows_by_host, wall.id, [])
            }
          )
        end

      {viewbox_min_x, viewbox_max_x} =
        for(wall <- walls, p <- [wall.from.x, wall.to.x], do: p)
        |> Enum.min_max()

      {viewbox_min_y, viewbox_max_y} =
        for(wall <- walls, p <- [wall.from.y, wall.to.y], do: p)
        |> Enum.min_max()

      viewbox_min_x = viewbox_min_x - 500
      viewbox_min_y = viewbox_min_y - 500
      viewbox_max_x = viewbox_max_x + 500
      viewbox_max_y = viewbox_max_y + 500

      viewbox =
        "#{viewbox_min_x} #{viewbox_min_y} #{viewbox_max_x - viewbox_min_x} #{viewbox_max_y - viewbox_min_y}"

      %{walls: walls, viewbox: viewbox}
      |> Jason.encode!()
      |> then(fn data -> File.write("priv/out/floorplan_revit_#{floor.id}.json", data) end)

      # Offline.render(
      #   :floorplan,
      #   %{walls: walls, viewbox: viewbox},
      #   "priv/out/floorplan_revit_#{floor.id}.html"
      # )
    end
  end
end
