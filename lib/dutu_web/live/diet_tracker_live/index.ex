defmodule DutuWeb.DietTrackerLive.Index do
  use DutuWeb, :live_view

  require Logger
  alias Dutu.DietTracker

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       foods: DietTracker.list_foods(),
       entries: %{},
       food_names: [],
       meal_time: nil
     )}
  end

  @impl true
  def handle_event("add_entry", params, socket) do
    entries =
      socket.assigns.entries
      |> Map.put(params["name"], String.to_integer(params["id"]))

    {:noreply,
     assign(socket,
       entries: entries,
       food_names: Map.keys(entries)
     )}
  end

  def handle_event("remove_entry", params, socket) do
    entries =
      socket.assigns.entries
      |> Map.delete(params["name"])

    {:noreply,
     assign(socket,
       entries: entries,
       food_names: Map.keys(entries)
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

    food_entry_attrs = Map.values(socket.assigns.entries) |> Enum.map(&%{food_id: &1})

    case DietTracker.create_tracker_entry(%{meal_time: meal_time, food_entries: food_entry_attrs}) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(entries: %{}, food_names: [], meal_time: nil)
         |> put_flash(:info, "Meal entries saved 👍")}

      {:error, changeset} ->
        Logger.error(changeset.errors)
        {:noreply, socket |> put_flash(:error, "Uh oh 😱 ... bad juju happened")}
    end
  end
end
