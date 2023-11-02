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

  scope "/" do
    pipe_through :browser
    pipe_through :admin

    ash_admin "/admin"
  end

  # Other scopes may use custom stacks.
  # scope "/api", RedWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:red, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RedWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
