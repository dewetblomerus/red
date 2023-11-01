defmodule Red.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :strategies, :auth0, :client_id],
        Red.Accounts.User,
        _
      ) do
    get_config(:client_id)
  end

  def secret_for(
        [:authentication, :strategies, :auth0, :redirect_uri],
        Red.Accounts.User,
        _
      ) do
    get_config(:redirect_uri)
  end

  def secret_for(
        [:authentication, :strategies, :auth0, :client_secret],
        Red.Accounts.User,
        _
      ) do
    get_config(:client_secret)
  end

  def secret_for(
        [:authentication, :strategies, :auth0, :site],
        Red.Accounts.User,
        _
      ) do
    get_config(:site)
  end

  defp get_config(key) do
    :red
    |> Application.fetch_env!(:auth0)
    |> Map.fetch!(key)
    |> then(&{:ok, &1})
  end
end
