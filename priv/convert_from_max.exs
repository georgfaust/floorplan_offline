defmodule MaxHelper do
  def to_xy(%{left: x, top: y}), do: %{x: x, y: y}
end

fp = File.read!("priv/floorplan_max_schema.json") |> Jason.decode!(keys: :atoms)

walls =
  for {id, wall} <- fp.walls do
    doors =
      for {door_id, door} <- Map.get(wall, :doors, []) do
        %{
          id: Atom.to_string(door_id),
          offset: door.start,
          width: door.length,
          din_direction: "right",
          flip: Map.get(door, :clockwise, false)
        }
      end

    windows =
      for {window_id, window} <- Map.get(wall, :windows, []) do
        %{
          id: Atom.to_string(window_id),
          offset: window.start,
          width: window.length
        }
      end

    from = MaxHelper.to_xy(wall.start)
    to = MaxHelper.to_xy(wall.end)
    direction = Vector.from_points(from, to) |> Vector.normalize()
    angle = Vector.right() |> Vector.angle(direction)
    id = Atom.to_string(id)

    %{
      id: id,
      from: from,
      to: to,
      width: 200,
      doors: doors,
      windows: windows,
      angle: angle,
      direction: direction,
      normal: Vector.normal(direction)
    }
  end

wall_index = Map.new(walls, &{&1.id, &1})

rooms =
  for room <- fp.rooms do
    corners =
      for [wall_ref, point] <- room.corners do
        wall_index[wall_ref][String.to_atom(point)]
      end

    Map.put(%{room | corners: corners}, :centroid, Polygon.centroid(corners))
  end

{viewbox_min_x, viewbox_max_x} =
  for(wall <- walls, p <- [wall.from.x, wall.to.x], do: p)
  |> Enum.min_max()

{viewbox_min_y, viewbox_max_y} =
  for(wall <- walls, p <- [wall.from.y, wall.to.y], do: p)
  |> Enum.min_max()

viewbox =
  "#{viewbox_min_x - 100} #{viewbox_min_y - 100} #{viewbox_max_x - viewbox_min_x + 200} #{viewbox_max_y - viewbox_min_y + 200}"

floorplan = %{walls: walls, viewbox: viewbox, rooms: rooms}

floorplan
|> Jason.encode!()
|> then(fn data -> File.write("priv/out/floorplan_max.json", data) end)

Offline.render(:floorplan, floorplan, "priv/out/floorplan_max.html")
