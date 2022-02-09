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

  alias Dutu.DietTracker.{TrackerEntry, FoodEntry}

  def create_tracker_entry(%{meal_time: _meal_time, food_entries: food_entry_attrs} = attrs)
      when is_list(food_entry_attrs) do
    %TrackerEntry{}
    |> TrackerEntry.changeset(attrs)
    |> Repo.insert()
  end

  def get_tracker_entry!(id), do: Repo.get!(TrackerEntry, id)

  def list_last_5_tracker_entries() do
    query =
      from te in TrackerEntry,
        join: tef in FoodEntry,
        on: tef.entry_id == te.id,
        join: f in Food,
        on: tef.food_id == f.id,
        group_by: [te.id],
        order_by: [desc: te.id],
        select: %{
          id: te.id,
          meal_time: te.meal_time,
          foods: fragment("string_agg(?, ', ' order by ?)", f.name, f.name)
        },
        limit: 5

    Repo.all(query)
  end

  def delete_tracker_entry(id) when is_integer(id) do
    try do
      get_tracker_entry!(id) |> Repo.delete()
    rescue
      Ecto.NoResultsError -> {:error, :not_found, "Entry with id #{id} not found"}
    end
  end
end
