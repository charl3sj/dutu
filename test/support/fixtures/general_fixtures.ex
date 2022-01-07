defmodule Dutu.GeneralFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dutu.General` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{
        due_date: ~D[2022-01-01],
        title: "some title"
      })
      |> Dutu.General.create_todo()

    todo
  end
end
