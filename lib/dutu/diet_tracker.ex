defmodule Dutu.DietTracker do
  @moduledoc """
  The DietTracker context.
  """

  import Ecto.Query, warn: false
  alias Dutu.Repo

  alias Dutu.DietTracker.Category

  def list_categories do
    Repo.all(Category)
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Dutu.DietTracker.Food

  def list_foods do
    Repo.all(from f in Food, order_by: [f.category_id, f.name])
    |> Repo.preload(:category)
  end

  def get_food!(id), do: Repo.get!(Food, id)

  def create_food(attrs \\ %{}) do
    %Food{}
    |> Food.changeset(attrs)
    |> Repo.insert()
  end

  def update_food(%Food{} = food, attrs) do
    food
    |> Food.changeset(attrs)
    |> Repo.update()
  end

  def delete_food(%Food{} = food) do
    Repo.delete(food)
  end

  def change_food(%Food{} = food, attrs \\ %{}) do
    Food.changeset(food, attrs)
  end

  alias Dutu.DietTracker.{TrackerEntry}

  def create_tracker_entry(%{meal_time: _meal_time, food_entries: food_entry_attrs} = attrs)
      when is_list(food_entry_attrs) do
    %TrackerEntry{}
    |> TrackerEntry.changeset(attrs)
    |> Repo.insert()
  end
end
