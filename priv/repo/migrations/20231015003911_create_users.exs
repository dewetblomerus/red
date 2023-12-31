defmodule Red.Repo.Migrations.CreateUsers do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
      add :email, :citext, null: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:users, [:email], name: "users_unique_email_index")
  end

  def down do
    drop_if_exists unique_index(:users, [:email], name: "users_unique_email_index")

    drop table(:users)
  end
end
