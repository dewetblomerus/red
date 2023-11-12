defmodule Red.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RedWeb.Telemetry,
      # Start the Ecto repository
      Red.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Red.PubSub},
      # Start Finch
      {Finch, name: Red.Finch},
      {AshAuthentication.Supervisor, otp_app: :example},
      Red.Words.BootLoader,
      # Start the Endpoint (http/https)
      RedWeb.Endpoint
      # Start a worker by calling: Red.Worker.start_link(arg)
      # {Red.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Red.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RedWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
