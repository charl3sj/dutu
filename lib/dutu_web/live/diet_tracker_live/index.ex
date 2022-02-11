defmodule DutuWeb.DietTrackerLive.Index do
  use DutuWeb, :live_view

  require Logger
  alias Dutu.DietTracker

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       foods: DietTracker.list_foods(),
       food_entries: %{},
       food_names: [],
       meal_time: nil,
       last_5_entries: DietTracker.list_last_5_tracker_entries()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Diet Tracker")
  end

  @impl true
  def handle_event("add_food", params, socket) do
    food_entries =
      socket.assigns.food_entries
      |> Map.put(params["name"], String.to_integer(params["id"]))

    {:noreply,
     assign(socket,
       food_entries: food_entries,
       food_names: Map.keys(food_entries)
     )}
  end

  def handle_event("remove_food", params, socket) do
    food_entries =
      socket.assigns.food_entries
      |> Map.delete(params["name"])

    {:noreply,
     assign(socket,
       food_entries: food_entries,
       food_names: Map.keys(food_entries)
     )}
  end

  def handle_event("set_meal_time", params, socket) do
    {:noreply,
     assign(socket,
       meal_time: params["meal_time"]
     )}
  end

  def handle_event("submit_entry", params, socket) do
    {:ok, meal_time} =
      case params["meal_time"] do
        "" -> {:ok, Dutu.DateHelpers.now()}
        datetime_str -> NaiveDateTime.from_iso8601(datetime_str)
      end

    food_entry_attrs = Map.values(socket.assigns.food_entries) |> Enum.map(&%{food_id: &1})

    case DietTracker.create_tracker_entry(%{meal_time: meal_time, food_entries: food_entry_attrs}) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(
           food_entries: %{},
           food_names: [],
           meal_time: nil,
           last_5_entries: DietTracker.list_last_5_tracker_entries()
         )
         |> put_flash(:info, "Food entries saved 👍")}

      {:error, changeset} ->
        Logger.error(changeset.errors)
        {:noreply, socket |> put_flash(:error, "Uh oh 😱 ... bad juju happened")}
    end
  end

  def handle_event("delete_db_entry", params, socket) do
    entry_id = String.to_integer(params["id"])

    case DietTracker.delete_tracker_entry(entry_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(last_5_entries: DietTracker.list_last_5_tracker_entries())
         |> put_flash(:info, "Entry deleted")}

      {:error, changeset} ->
        Logger.error(changeset.errors)
        {:noreply, socket |> put_flash(:error, "Uh oh 😱 ... bad juju happened")}

      {:error, :not_found, error_msg} ->
        Logger.error(error_msg)
        {:noreply, socket |> put_flash(:error, error_msg)}
    end
  end
end
