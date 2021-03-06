defmodule Dutu.DietTrackerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dutu.DietTracker` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Dutu.DietTracker.create_category()

    category
  end

  @doc """
  Generate a food.
  """
  def food_fixture(attrs \\ %{}) do
    category =
      category_fixture(%{
        name:
          if Map.has_key?(attrs, :category_name) and attrs.category_name not in [nil, ""] do
            attrs.category_name
          else
            "some name"
          end
      })

    {:ok, food} =
      attrs
      |> Enum.into(%{
        name: "some name",
        category_id: category.id
      })
      |> Dutu.DietTracker.create_food()

    food
  end
end
