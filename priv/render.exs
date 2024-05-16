defmodule RenderHelper do
  def render_one(basename) do
    "priv/out/#{basename}.json"
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
    |> then(fn fp -> Offline.render(:floorplan, fp, "priv/out/#{basename}.html") end)
  end
end

RenderHelper.render_one("floorplan_revit_1213356")
RenderHelper.render_one("floorplan_revit_1213387")
RenderHelper.render_one("floorplan_max")
