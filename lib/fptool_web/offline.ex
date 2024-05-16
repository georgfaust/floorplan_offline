defmodule Offline do
  use Phoenix.Component
  embed_templates("templates/*")

  def render(template, assigns, path \\ nil) do
    rendered = apply(__MODULE__, template, [assigns]) |> Phoenix.HTML.Safe.to_iodata()
    write_result = if path, do: File.write!(path, rendered)
    {write_result, to_string(rendered)}
  end
end
