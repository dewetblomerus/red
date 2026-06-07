defmodule Red.Factory do
  alias Red.Accounts.User
  alias Red.Practice.Card

  def admin_user do
    user_info = %{
      "email_verified" => true,
      "email" => "dewetblomerus@gmail.com",
      "name" => "De Wet",
      "sub" => "google-oauth2|redacted",
      "picture" => "https://picture-url.com"
    }

    User
    |> Ash.Changeset.for_action(
      :register_with_auth0,
      %{
        user_info: user_info,
        oauth_tokens: %{}
      }
    )
    |> Ash.create!()
  end

  def user_factory do
    User
    |> Ash.Changeset.for_action(
      :register_with_auth0,
      %{
        user_info: user_info(),
        oauth_tokens: %{}
      }
    )
    |> Ash.create!()
  end

  def user_info(attrs \\ %{}) do
    unique = System.unique_integer([:positive])

    Map.merge(
      %{
        "email_verified" => Enum.random([true, false]),
        "email" => "user-#{unique}@example.com",
        "name" => "Test User #{unique}",
        "sub" => "google-oauth2|#{unique}",
        "picture" => "https://example.com/users/#{unique}.jpg"
      },
      attrs
    )
  end

  def card_factory(user, opts \\ %{}) do
    Card.create!(
      %{
        phrase: random_string(),
        word: random_string(40),
        retry_at: Map.get(opts, :retry_at),
        tried_at: Map.get(opts, :tried_at)
      },
      actor: user
    )
  end

  defp random_string(length \\ 16) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end
end
