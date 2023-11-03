defmodule RedWeb.Router do
  use RedWeb, :router
  use AshAuthentication.Phoenix.Router
  import AshAdmin.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RedWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  pipeline :admin do
    plug RedWeb.AdminChecker
  end

  scope "/", RedWeb do
    pipe_through :browser

    get "/about", PageController, :about
    get "/home", PageController, :home
    get "/privacy", PageController, :privacy

    sign_in_route()
    sign_out_route AuthController
    auth_routes_for Red.Accounts.User, to: AuthController
    reset_route []

    ash_authentication_live_session :authentication_required,
      on_mount: {RedWeb.LiveUserAuth, :live_user_home} do
      live "/", PracticeLive
      live "/words", WordsLive
    end
  end

  import Phoenix.LiveDashboard.Router

  scope "/admin" do
    pipe_through :browser
    pipe_through :admin

    ash_admin "/ash"
    live_dashboard "/dashboard", metrics: RedWeb.Telemetry
  end

  if Application.compile_env(:red, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
