defmodule Red.Repo do
  use AshPostgres.Repo,
    otp_app: :red

  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
