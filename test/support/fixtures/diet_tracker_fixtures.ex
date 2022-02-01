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
end
