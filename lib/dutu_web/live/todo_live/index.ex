defmodule DutuWeb.TodoLive.Index do
  use DutuWeb, :live_view

  alias Dutu.General
  alias Dutu.General.Todo
  alias Dutu.General.TodoForm
  use Dutu.DateHelpers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :todos, list_todos())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    todo = General.get_todo!(id)

    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, todo)
    |> assign(:todo_form, todo |> General.TodoForm.from_todo())
    |> assign(:due_date_types, @due_date_types)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
    |> assign(:todo_form, %TodoForm{})
    |> assign(:due_date_types, @due_date_types)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Todos")
    |> assign(:todo, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = General.get_todo!(id)
    {:ok, _} = General.delete_todo(todo)

    {:noreply, assign(socket, :todos, list_todos())}
  end

  defp list_todos do
    General.list_todos() |> segment_todos()
  end

  defp segment_todos(todos) do
    this_years = todos |> General.filter_todos_by_period(:this_year)
    this_quarters = this_years |> General.filter_todos_by_period(:this_quarter)
    this_months = this_quarters |> General.filter_todos_by_period(:this_month)
    this_weeks = this_months |> General.filter_todos_by_period(:this_week)
    todays = todos |> General.filter_todos_by_period(:today)
    tomorrows = todos |> General.filter_todos_by_period(:tomorrow)
    pending = todos |> General.filter_pending_todos()
    undefined = todos |> General.filter_todos_by_period(:undefined)

    # to avoid overlaps because of approx due dates
    tomorrows_unique = tomorrows |> Enum.reject(&(&1 in (pending ++ todays)))
    this_weeks_unique = this_weeks |> Enum.reject(&(&1 in (pending ++ todays ++ tomorrows)))

    this_months_unique =
      this_months |> Enum.reject(&(&1 in (this_weeks ++ pending ++ todays ++ tomorrows)))

    this_quarters_unique =
      this_quarters
      |> Enum.reject(&(&1 in (this_months ++ this_weeks ++ pending ++ todays ++ tomorrows)))

    this_years_unique =
      this_years
      |> Enum.reject(
        &(&1 in (this_quarters ++ this_months ++ this_weeks ++ pending ++ todays ++ tomorrows))
      )

    future =
      todos
      |> Enum.reject(
        &(&1 in (undefined ++
                   this_years ++
                   this_quarters ++ this_months ++ this_weeks ++ pending ++ todays ++ tomorrows))
      )

    %{
      pending: pending,
      today: todays,
      tomorrow: tomorrows_unique,
      this_week: this_weeks_unique,
      this_month: this_months_unique,
      this_quarter: this_quarters_unique,
      this_year: this_years_unique,
      future: future,
      undefined: undefined
    }
  end
end
