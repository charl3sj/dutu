defmodule Dutu.Repo.Migrations.CreateFoods do
  use Ecto.Migration

  def change do
    create table(:foods) do
      add :name, :string, null: false
      add :category_id, references(:categories, on_delete: :delete_all), null: false
      add :quota, :map
    end

    create unique_index(:foods, [:name, :category_id])
  end
end
