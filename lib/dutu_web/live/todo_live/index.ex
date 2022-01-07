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
    |> assign(:todo_form, todo |> General.TodoForm.from_todo)
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
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = General.get_todo!(id)
    {:ok, _} = General.delete_todo(todo)

    {:noreply, assign(socket, :todos, list_todos())}
  end

  defp list_todos do
    General.list_todos()
  end
end
