defmodule Dutu.General do
  @moduledoc """
  The General context.
  """

  import Ecto.Query, warn: false
  alias Dutu.Repo

  alias Dutu.General.Todo
  alias Dutu.General.TodoForm
  alias Dutu.General.Chore
  alias Dutu.General.ChoreForm

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

  alias Dutu.General.Chore

  def list_chores do
    Repo.all(Chore)
  end

  def get_chore!(id), do: Repo.get!(Chore, id)

  def create_chore(attrs \\ %{}) do
    %Chore{}
    |> Chore.changeset(attrs)
    |> Repo.insert()
  end

  def update_chore(%Chore{} = chore, attrs) do
    chore
    |> Chore.changeset(attrs)
    |> Repo.update()
  end

  def delete_chore(%Chore{} = chore) do
    Repo.delete(chore)
  end

  def mark_chore_as_done(%Chore{} = chore) do
    chore
    |> update_chore(%{last_done_at: Timex.now("Asia/Calcutta")})
  end

  def change_chore(%Chore{} = chore, attrs \\ %{}) do
    Chore.changeset(chore, attrs)
  end

  def change_chore_form(%ChoreForm{} = form, attrs \\ %{}) do
    ChoreForm.changeset(form, attrs)
  end

  def filter_chores_by_frequency(chores, :daily), do: chores |> Enum.filter(& Chore.recurs_every_x_days? &1)
  def filter_chores_by_frequency(chores, :weekly), do: chores |> Enum.filter(& Chore.recurs_every_week? &1)

  def filter_chores_due_today(chores), do: Enum.filter(chores, & Chore.due_on_date?(&1, Timex.today()))

end
