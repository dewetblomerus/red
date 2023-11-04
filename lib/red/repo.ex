defmodule Red.Repo do
  use AshPostgres.Repo,
    otp_app: :red

  def installed_extensions do
    [
      "ash-functions",
      "citext",
      "uuid-ossp"
    ]
  end
end
