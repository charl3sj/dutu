defmodule DutuWeb.FoodLive.Index do
  use DutuWeb, :live_view

  alias Dutu.DietTracker
  alias Dutu.DietTracker.Food

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :foods, list_foods())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Food")
    |> assign(:food, DietTracker.get_food!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Food")
    |> assign(:food, %Food{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Foods")
    |> assign(:food, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    food = DietTracker.get_food!(id)
    {:ok, _} = DietTracker.delete_food(food)

    {:noreply, assign(socket, :foods, list_foods())}
  end

  defp list_foods do
    DietTracker.list_foods()
  end
end
