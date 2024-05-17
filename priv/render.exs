defmodule RenderHelper do
  def render_one(basename) do
    "priv/out/#{basename}.json"
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
    |> then(fn fp -> Offline.render(:floorplan, fp, "priv/out/#{basename}.html") end)
  end
end

# NOTE: the revit version has no rooms defined and its not feasible to do them per hand, so we first need sth to easily define rooms before we can use those
# RenderHelper.render_one("floorplan_revit_1213356")
# RenderHelper.render_one("floorplan_revit_1213387")
RenderHelper.render_one("floorplan_max")
