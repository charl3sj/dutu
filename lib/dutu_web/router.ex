defmodule DutuWeb.Router do
  use DutuWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DutuWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DutuWeb do
    pipe_through :browser

    live "/", TodayLive.Index, :index
    live "/done/:item/:id", TodayLive.Index, :update
    live "/todos", TodoLive.Index, :index
    live "/todos/new", TodoLive.Index, :new
    live "/todos/:id/edit", TodoLive.Index, :edit
    live "/chores", ChoreLive.Index, :index
    live "/chores/new", ChoreLive.Index, :new
    live "/chores/:id/edit", ChoreLive.Index, :edit
    live "/foods", FoodLive.Index, :index
    live "/foods/new", FoodLive.Index, :new
    live "/foods/:id/edit", FoodLive.Index, :edit
    live "/foods/category/new", FoodLive.Index, :new_category
    live "/foods/category/:id/edit", FoodLive.Index, :edit_category
    live "/diet", DietTrackerLive.Index, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", DutuWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DutuWeb.Telemetry
    end
  end
end
