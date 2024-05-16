defmodule VectorM do
  def sub(a, b), do: %{x: a.x - b.x, y: a.y - b.y}
  def add(a, b), do: %{x: a.x + b.x, y: a.y + b.y}
  def s_mul(a, s), do: %{x: a.x * s, y: a.y * s}
  def dot(a, b), do: a.x * b.x + a.y * b.y
  def det(a, b), do: a.x * b.y - a.y * b.x
  def cross(a, b), do: det(a, b)
  def len(a), do: :math.sqrt(a.x * a.x + a.y * a.y)
  def normalize(a), do: s_mul(a, 1 / len(a))
  def angle(a, b), do: :math.atan2(cross(a, b), dot(a, b)) |> to_deg
  def from_angle(theta), do: %{x: :math.cos(to_rad(theta)), y: :math.sin(to_rad(theta))}
  def to_rad(deg), do: deg * :math.pi() / 180
  def to_deg(rad), do: rad * 180 / :math.pi()
  def normal(a), do: %{x: -a.y, y: a.x}
  def invert(a), do: s_mul(a, -1)
  def distance(p1, p2), do: from_points(p1, p2) |> len
  def from_points(p1, p2), do: %{x: p2.x - p1.x, y: p2.y - p1.y}
  def right(), do: %{x: 1, y: 0}
  def down(), do: %{x: 0, y: 1}
  def left(), do: %{x: -1, y: 0}
  def up(), do: %{x: 0, y: -1}
  def origin(), do: %{x: 0, y: 0}

  def rotate(a, theta) do
    theta_ = to_rad(theta)
    cos_theta = :math.cos(theta_)
    sin_theta = :math.sin(theta_)

    %{
      x: cos_theta * a.x - sin_theta * a.y,
      y: sin_theta * a.x + cos_theta * a.y
    }
  end

  def max_by_dimension(vectors, dimension) do
    vectors |> Enum.map(& &1[dimension]) |> Enum.max()
  end

  def min_by_dimension(vectors, dimension) do
    vectors |> Enum.map(& &1[dimension]) |> Enum.min()
  end
end

defmodule LinesM do
  # https://stackoverflow.com/a/20677983
  def intersect({a1, b1}, {a2, b2}) do
    x_diff = %{x: a1.x - b1.x, y: a2.x - b2.x}
    y_diff = %{x: a1.y - b1.y, y: a2.y - b2.y}

    diff_det = VectorM.det(x_diff, y_diff)

    cond do
      diff_det == 0 ->
        :no_intersection

      true ->
        d = %{x: VectorM.det(a1, b1), y: VectorM.det(a2, b2)}
        %{x: VectorM.det(d, x_diff) / diff_det, y: VectorM.det(d, y_diff) / diff_det}
    end
  end
end

defmodule PolygonM do
  def centroid(vertices) do
    vertices
    |> Enum.reduce({0, 0}, fn v, acc_v -> VectorM.add(v, acc_v) end)
    |> VectorM.s_mul(1 / length(vertices))
  end
end
