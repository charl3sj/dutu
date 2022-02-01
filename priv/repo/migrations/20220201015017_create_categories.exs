defmodule Dutu.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
    end

    create unique_index(:categories, [:name])
  end
end
