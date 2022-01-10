defmodule Dutu.Repo.Migrations.CreateChores do
  use Ecto.Migration

  def change do
    create table(:chores) do
      add :title, :string, null: false
      add :rrule, :map
      add :last_done_at, :naive_datetime
    end
  end
end
