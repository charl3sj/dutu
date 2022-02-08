defmodule Dutu.Repo.Migrations.CreateMealLogs do
  use Ecto.Migration

  def change do
    create table(:tracker_entries) do
      add :meal_time, :naive_datetime, null: false
      timestamps()
    end

    create table(:tracker_entries_foods, primary_key: false) do
      add :entry_id, references(:tracker_entries, on_delete: :delete_all), null: false
      add :food_id, references(:foods, on_delete: :nilify_all), null: false
    end

    create index(:tracker_entries_foods, [:entry_id])
    create index(:tracker_entries_foods, [:food_id])
  end
end
