defmodule Dutu.General do
  @moduledoc """
  The General context.
  """

  import Ecto.Query, warn: false
  alias Dutu.Repo

  alias Dutu.General.Todo
  alias Dutu.General.TodoForm

  def fill_todo_virtual_fields(todo) do
    todo
    |> Todo.put_formatted_date()
  end

  def list_all_todos, do: Repo.all(Todo)

  def list_todos do
    Repo.all(from t in Todo, where: t.is_done == false)
    |> Enum.map(& fill_todo_virtual_fields &1)
  end

  def get_todo!(id) do
    Repo.get!(Todo, id)
    |> fill_todo_virtual_fields()
  end

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

  def change_todo_form(%TodoForm{} = form, attrs \\ %{}) do
    TodoForm.changeset(form, attrs)
  end

  def filter_todos_by_period(todos, period) do
    case period do
      :today -> todos |> Enum.filter(& Todo.due_today? &1)
      :tomorrow -> todos |> Enum.filter(& Todo.due_tomorrow? &1)
      :this_week -> todos |> Enum.filter(& Todo.due_this_week? &1)
      :this_month -> todos |> Enum.filter(& Todo.due_this_month? &1)
      :this_quarter -> todos |> Enum.filter(& Todo.due_this_quarter? &1)
      :this_year -> todos |> Enum.filter(& Todo.due_this_year? &1)
      :undefined -> todos |> Enum.filter(& Todo.due_date_undefined? &1)
    end
  end

  def filter_pending_todos(todos) do
    todos |> Enum.filter(& Todo.due_before?(&1, Timex.today("Asia/Calcutta")))
  end
end
