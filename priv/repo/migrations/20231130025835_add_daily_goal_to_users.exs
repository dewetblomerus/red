defmodule Red.Repo.Migrations.AddDailyGoalToUsers do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      add :daily_goal, :bigint, null: false, default: 10
    end
  end

  def down do
    alter table(:users) do
      remove :daily_goal
    end
  end
end
