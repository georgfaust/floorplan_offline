defmodule Vector do
  def v(%{x: x, y: y}), do: {x, y}
  def sub({a1, a2}, {b1, b2}), do: {a1 - b1, a2 - b2}
  def add({a1, a2}, {b1, b2}), do: {a1 + b1, a2 + b2}
  def add2(%{x: a1, y: a2}, %{x: b1, y: b2}), do: %{x: a1 + b1, y: a2 + b2}
  def s_mul({a1, a2}, s), do: {a1 * s, a2 * s}
  def dot({a1, a2}, {b1, b2}), do: a1 * b1 + a2 * b2
  def det({a1, a2}, {b1, b2}), do: a1 * b2 - a2 * b1
  def cross(a, b), do: det(a, b)
  def len({a1, a2}), do: :math.sqrt(a1 * a1 + a2 * a2)
  def normalize(a), do: s_mul(a, 1 / len(a))
  def angle(a, b), do: :math.atan2(cross(a, b), dot(a, b)) |> to_deg
  def from_angle(theta), do: {:math.cos(to_rad(theta)), :math.sin(to_rad(theta))}
  def to_rad(deg), do: deg * :math.pi() / 180
  def to_deg(rad), do: rad * 180 / :math.pi()
  def normal({a1, a2}), do: {-a2, a1}
  def invert(a), do: s_mul(a, -1)
  def slope({x, _}, {x, _}), do: :vertical
  def slope({x1, y1}, {x2, y2}), do: (y2 - y1) / (x2 - x1)
  def from_points({p1x, p1y}, {p2x, p2y}), do: {p2x - p1x, p2y - p1y}
  def as_map({x, y}), do: %{x: x, y: y}
  def right(), do: {1, 0}
  def down(), do: {0, 1}
  def left(), do: {-1, 0}
  def up(), do: {0, -1}
end

defmodule Lines do
  # https://stackoverflow.com/a/20677983
  def intersect({{a1x, a1y} = a1, {b1x, b1y} = b1}, {{a2x, a2y} = a2, {b2x, b2y} = b2}) do
    x_diff = {a1x - b1x, a2x - b2x}
    y_diff = {a1y - b1y, a2y - b2y}

    diff_det = Vector.det(x_diff, y_diff)

    cond do
      diff_det == 0 ->
        :no_intersection

      true ->
        d = {Vector.det(a1, b1), Vector.det(a2, b2)}
        {Vector.det(d, x_diff) / diff_det, Vector.det(d, y_diff) / diff_det}
    end
  end
end

defmodule Polygon do
  def centroid(vertices) do
    vertices
    |> Enum.reduce({0, 0}, fn {vx, vy}, {x, y} -> {x + vx, y + vy} end)
    |> Vector.s_mul(1 / length(vertices))
  end
end
