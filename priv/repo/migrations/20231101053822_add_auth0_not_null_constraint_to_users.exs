defmodule Red.Repo.Migrations.AddAuth0NotNullConstraintToUsers do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      modify :auth0_id, :text, null: false
    end
  end

  def down do
    alter table(:users) do
      modify :auth0_id, :text, null: true
    end
  end
end
