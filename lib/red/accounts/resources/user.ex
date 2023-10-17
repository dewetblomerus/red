defmodule Red.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    integer_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    create_timestamp :created_at
    create_timestamp :updated_at
  end

  relationships do
    # `has_many` means that the destination attribute is not unique, therefore many related records could exist.
    # We assume that the destination attribute is `representative_id` based
    # on the module name of this resource and that the source attribute is `id`.
    has_many :attempts, Red.Practice.Attempt
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
  end

  actions do
    create :register_with_auth0 do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false
      upsert? true
      upsert_identity :unique_email

      # Required if you have token generation enabled.
      change AshAuthentication.GenerateTokenChange

      # Required if you have the `identity_resource` configuration enabled.
      change AshAuthentication.Strategy.OAuth2.IdentityChange

      change fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)

        Ash.Changeset.change_attributes(changeset, Map.take(user_info, ["email"]))
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
