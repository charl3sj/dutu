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

  defp get_weekly_monthly_bounds() do
    {:ok, month_start} =
      Dutu.DateHelpers.start_of_this_month()
      |> NaiveDateTime.new(~T[00:00:00])

    {:ok, month_end} =
      Dutu.DateHelpers.start_of_this_month()
      |> Timex.end_of_month()
      |> NaiveDateTime.new(~T[23:59:59])

    {:ok, week_start} =
      Dutu.DateHelpers.start_of_this_week()
      |> NaiveDateTime.new(~T[00:00:00])

    {:ok, week_end} =
      Dutu.DateHelpers.start_of_this_week()
      |> Timex.end_of_week()
      |> NaiveDateTime.new(~T[23:59:59])

    {month_start, month_end, week_start, week_end}
  end

  def list_and_rank_foods_by_current_month_consumption() do
    {month_start, month_end, week_start, week_end} = get_weekly_monthly_bounds()
    today = Dutu.DateHelpers.today()

    inner_query =
      from te in TrackerEntry,
        join: tef in FoodEntry,
        on: tef.entry_id == te.id,
        select: %{
          food_id: tef.food_id,
          count: count(),
          count_this_week:
            count() |> filter(te.meal_time >= ^week_start and te.meal_time <= ^week_end),
          count_today: count() |> filter(fragment("?::date", te.meal_time) == ^today)
        },
        where: te.meal_time >= ^month_start and te.meal_time <= ^month_end,
        group_by: [tef.food_id]

    query =
      from f in Food,
        preload: [:category],
        left_join: s in subquery(inner_query),
        on: s.food_id == f.id,
        select: %{
          food: f,
          count: s.count,
          rank:
            dense_rank()
            |> over(partition_by: f.category_id, order_by: [asc_nulls_first: s.count]),
          count_this_week: s.count_this_week,
          count_today: s.count_today,
          day_min_reached:
            fragment(
              "CASE WHEN count_today >= (?#>>'{min,per_day}')::int THEN true ELSE false END",
              f.quota
            ),
          week_min_reached:
            fragment(
              "CASE WHEN count_this_week >= (?#>>'{min,per_week}')::int THEN true ELSE false END",
              f.quota
            ),
          month_min_reached:
            fragment(
              "CASE WHEN count >= (?#>>'{min,per_month}')::int THEN true ELSE false END",
              f.quota
            ),
          day_max_reached:
            fragment(
              "CASE WHEN count_today >= (?#>>'{max,per_day}')::int THEN true ELSE false END",
              f.quota
            ),
          week_max_reached:
            fragment(
              "CASE WHEN count_this_week >= (?#>>'{max,per_week}')::int THEN true ELSE false END",
              f.quota
            ),
          month_max_reached:
            fragment(
              "CASE WHEN count >= (?#>>'{max,per_month}')::int THEN true ELSE false END",
              f.quota
            )
        }

    Repo.all(query)
  end
end
