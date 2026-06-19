defmodule Red.Repo.Migrations.CreateUserIdentities do
  @moduledoc """
  Adds a user identities table for Ash Authentication OAuth/OIDC providers.
  """

  use Ecto.Migration

  def up do
    create table(:user_identities, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true, default: fragment("gen_random_uuid()")
      add :strategy, :text, null: false
      add :uid, :text, null: false
      add :access_token, :text
      add :access_token_expires_at, :utc_datetime_usec
      add :refresh_token, :text

      add :user_id,
          references(:users,
            column: :id,
            name: "user_identities_user_id_fkey",
            type: :bigint
          )
    end

    create unique_index(:user_identities, [:strategy, :uid],
             name: "user_identities_unique_on_strategy_and_uid_index"
           )
  end

  def down do
    drop_if_exists unique_index(:user_identities, [:strategy, :uid],
                     name: "user_identities_unique_on_strategy_and_uid_index"
                   )

    drop table(:user_identities)
  end
end
