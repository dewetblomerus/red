defmodule Red.Repo do
  use Ecto.Repo,
    otp_app: :red,
    adapter: Ecto.Adapters.Postgres
end
