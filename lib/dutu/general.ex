defmodule Dutu.General do
  @moduledoc """
  The General context.
  """

  import Ecto.Query, warn: false
  alias Dutu.Repo

  alias Dutu.General.Todo

  def fill_todo_virtual_fields(todos) do
    todos
    |> Enum.map(&Todo.put_formatted_date(&1))
  end

  def list_all_todos, do: Repo.all(Todo)

  def list_todos do
    Repo.all(from t in Todo, where: t.is_done == false)
    |> fill_todo_virtual_fields()
  end

  def get_todo!(id), do: Repo.get!(Todo, id)

  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  def mark_todo_as_done(%Todo{} = todo) do
    attrs = %{is_done: true, done_at: Timex.now("Asia/Calcutta")}
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end
end
