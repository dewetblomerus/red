defmodule Red.Accounts.UserTest do
  use Red.DataCase, async: true
  alias Red.Accounts.User

  describe "register_with_auth0/1" do
    test "creates a new user" do
      assert %User{
               auth0_id: "google-oauth2|redacted",
               daily_goal: 10,
               email_verified: true,
               email: %Ash.CiString{string: "dewetblomerus@gmail.com"},
               name: "De Wet",
               picture: "https://picture-url.com"
             } = Red.Factory.admin_user()
    end

    test "updates an existing user" do
      user = Red.Factory.user_factory()

      user_info = %{
        "email_verified" => true,
        "email" => Faker.Internet.email(),
        "name" => Faker.Person.name(),
        "sub" => user.auth0_id,
        "picture" => Faker.Internet.url()
      }

      updated_user =
        User
        |> Ash.Changeset.for_action(
          :register_with_auth0,
          %{
            user_info: user_info,
            oauth_tokens: %{}
          }
        )
        |> Red.Accounts.create!()

      auth0_id = user.auth0_id
      email = user_info["email"]
      name = user_info["name"]
      picture = user_info["picture"]

      assert %User{
               auth0_id: auth0_id,
               daily_goal: 10,
               email_verified: true,
               email: %Ash.CiString{string: ^email},
               name: ^name,
               picture: ^picture
             } = updated_user
    end
  end
end
