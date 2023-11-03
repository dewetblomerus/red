defmodule Red.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    integer_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    attribute :auth0_id, :string, allow_nil?: false, private?: true
    attribute :email_verified, :boolean
    attribute :picture, :string
    attribute :name, :string

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :cards, Red.Practice.Card
  end

  aggregates do
    count :count_cards_reviewed_today, :cards do
      filter expr(tried_at >= ago(10, :hour))
    end
  end

  authentication do
    api Red.Accounts

    strategies do
      auth0 do
        client_id Red.Secrets
        redirect_uri Red.Secrets
        client_secret Red.Secrets
        site Red.Secrets
      end
    end
  end

  postgres do
    table "users"
    repo Red.Repo
  end

  identities do
    identity :unique_email, [:email]
    identity :unique_auth0_id, [:auth0_id]
  end

  actions do
    create :register_with_auth0 do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false
      upsert? true
      upsert_identity :unique_auth0_id

      # Required if you have token generation enabled.
      change AshAuthentication.GenerateTokenChange

      # Required if you have the `identity_resource` configuration enabled.
      change AshAuthentication.Strategy.OAuth2.IdentityChange

      change fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)

        changes =
          user_info
          |> Map.take([
            "email_verified",
            "email",
            "name",
            "picture"
          ])
          |> Map.put("auth0_id", Map.get(user_info, "sub"))

        Ash.Changeset.change_attributes(
          changeset,
          changes
        )
      end
    end

    read :read do
      primary? true
    end

    read :get_by do
      get_by [:email]
    end
  end

  code_interface do
    define_for Red.Accounts

    define :get_by, action: :get_by
  end
end
