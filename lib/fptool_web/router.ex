defmodule FptoolWeb.Router do
  use FptoolWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FptoolWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FptoolWeb do
    pipe_through :browser

    live "/", DemoLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", FptoolWeb do
  #   pipe_through :api
  # end
end
