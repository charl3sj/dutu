defmodule DutuWeb.FoodLive.FoodForm do
  use DutuWeb, :live_component

  alias Dutu.DietTracker

  @impl true
  def update(%{food: food} = assigns, socket) do
    changeset = DietTracker.change_food(food)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"food" => food_params}, socket) do
    changeset =
      socket.assigns.food
      |> DietTracker.change_food(food_params)
      |> Map.put(:action, :validate)

    IO.inspect(changeset)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"food" => food_params}, socket) do
    save_food(socket, socket.assigns.action, food_params)
  end

  defp save_food(socket, :edit, food_params) do
    case DietTracker.update_food(socket.assigns.food, food_params) do
      {:ok, _food} ->
        {:noreply,
         socket
         |> put_flash(:info, "Food updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_food(socket, :new, food_params) do
    case DietTracker.create_food(food_params) do
      {:ok, _food} ->
        {:noreply,
         socket
         |> put_flash(:info, "Food created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
