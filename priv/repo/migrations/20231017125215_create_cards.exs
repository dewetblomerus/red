defmodule Red.Repo.Migrations.CreateCards do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:cards, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
      add :word, :text, null: false
      add :tried_at, :utc_datetime
      add :retry_at, :utc_datetime
      add :correct_streak, :bigint, null: false, default: 0
      add :created_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")

      add :user_id,
          references(:users,
            column: :id,
            name: "cards_user_id_fkey",
            type: :bigint,
            prefix: "public"
          ),
          null: false
    end

    create unique_index(:cards, [:word, :user_id], name: "cards_unique_word_index")
  end

  def down do
    drop_if_exists unique_index(:cards, [:word, :user_id], name: "cards_unique_word_index")

    drop constraint(:cards, "cards_user_id_fkey")

    drop table(:cards)
  end
end