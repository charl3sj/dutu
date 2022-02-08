defmodule Dutu.DietTracker.FoodEntry do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dutu.DietTracker.{Food, TrackerEntry, FoodEntry}

  @primary_key false
  schema "tracker_entries_foods" do
    belongs_to :entry, TrackerEntry
    belongs_to :food, Food
  end

  @doc false
  def changeset(%FoodEntry{} = food_entry, attrs) do
    food_entry
    |> cast(attrs, [:entry_id, :food_id])
    |> validate_required([:entry_id, :food_id])
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:food_id)
  end

  @doc false
  def partial_changeset(%FoodEntry{} = food_entry, attrs) do
    food_entry
    |> cast(attrs, [:entry_id, :food_id])
    |> validate_required([:food_id])
    |> foreign_key_constraint(:entry_id)
    |> foreign_key_constraint(:food_id)
  end
end
