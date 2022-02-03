defmodule DutuWeb.FoodLive.Index do
  use DutuWeb, :live_view

  alias Dutu.DietTracker
  alias Dutu.DietTracker.{Category, Food}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       foods: list_foods(),
       categories: DietTracker.list_categories()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Food")
    |> assign(:food, DietTracker.get_food!(id))
    |> assign(:categories, DietTracker.list_categories())
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Food")
    |> assign(:food, %Food{})
    |> assign(:categories, DietTracker.list_categories())
  end

  defp apply_action(socket, :new_category, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :edit_category, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, DietTracker.get_category!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Foods")
    |> assign(:food, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    food = DietTracker.get_food!(id)
    {:ok, _} = DietTracker.delete_food(food)

    {:noreply,
     assign(socket,
       foods: list_foods(),
       categories: DietTracker.list_categories()
     )}
  end

  @impl true
  def handle_event("delete-category", %{"id" => id}, socket) do
    category = DietTracker.get_category!(id)
    {:ok, _} = DietTracker.delete_category(category)

    {:noreply,
     assign(socket,
       foods: list_foods(),
       categories: DietTracker.list_categories()
     )}
  end

  defp list_foods do
    DietTracker.list_foods()
  end
end
