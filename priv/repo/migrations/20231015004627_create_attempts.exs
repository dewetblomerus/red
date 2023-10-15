defmodule Red.Repo.Migrations.CreateAttempts do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:attempts, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
      add :tried_spelling, :text, null: false
      add :correct_spelling, :text, null: false
      add :created_at, :utc_datetime_usec, null: false, default: fragment("now()")

      add :user_id,
          references(:users,
            column: :id,
            name: "attempts_user_id_fkey",
            type: :bigint,
            prefix: "public"
          ),
          null: false
    end
  end

  def down do
    drop constraint(:attempts, "attempts_user_id_fkey")

    drop table(:attempts)
  end
end