defmodule Red.Factory do
  alias Red.Accounts.User

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
    |> Red.Accounts.create!()
  end

  def user_factory do
    user_info = %{
      "email_verified" => Enum.random([true, false]),
      "email" => Faker.Internet.email(),
      "name" => Faker.Person.name(),
      "sub" => "google-oauth2|#{System.unique_integer([:positive])}",
      "picture" => Faker.Internet.url()
    }

    User
    |> Ash.Changeset.for_action(
      :register_with_auth0,
      %{
        user_info: user_info,
        oauth_tokens: %{}
      }
    )
    |> Red.Accounts.create!()
  end
end
