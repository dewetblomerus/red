defmodule Red.Repo.Migrations.CreateWords do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:words, primary_key: false) do
      add :word, :text, null: false, primary_key: true
    end
  end

  def down do
    drop table(:words)
  end
end
