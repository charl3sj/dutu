defmodule DutuWeb.TodayLive.Index do
  use DutuWeb, :live_view

  alias Dutu.General

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:todos, list_todos())
     |> assign(:chores, list_chores())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Today")
  end

  @impl true
  def handle_event("mark_as_done", %{"id" => id, "item-type" => "todo"} = _params, socket) do
    todo = General.get_todo!(String.to_integer(id))
    General.mark_todo_as_done(todo)
    {:noreply, assign(socket, :todos, list_todos())}
  end

  def handle_event("mark_as_done", %{"id" => id, "item-type" => "chore"} = _params, socket) do
    chore = General.get_chore!(String.to_integer(id))
    General.mark_chore_as_done(chore)
    {:noreply, assign(socket, :chores, list_chores())}
  end

  defp list_todos do
    all = General.list_todos()
    todays = all |> General.filter_todos_by_period(:today)
    pending = all |> General.filter_pending_todos()
    pending ++ todays
  end

  defp list_chores do
    General.list_chores() |> General.filter_chores_due_today()
  end
end
