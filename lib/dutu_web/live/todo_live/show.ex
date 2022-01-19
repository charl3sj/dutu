defmodule DutuWeb.TodoLive.Show do
  use DutuWeb, :live_view

  alias Dutu.General
  use Dutu.DateHelpers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    todo = General.get_todo!(id)
    IO.inspect(todo)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:todo, todo)
     |> assign(:todo_form, todo |> General.TodoForm.from_todo())
     |> assign(:due_date_types, @due_date_types)}
  end

  defp page_title(:show), do: "Show Todo"
  defp page_title(:edit), do: "Edit Todo"
end
