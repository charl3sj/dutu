defmodule Dutu.DietTracker.TrackerEntry do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dutu.DietTracker.{TrackerEntry, FoodEntry}

  schema "tracker_entries" do
    field :meal_time, :naive_datetime
    has_many :food_entries, FoodEntry, foreign_key: :entry_id
    timestamps()
  end

  @doc false
  def changeset(%TrackerEntry{} = tracker_entry, attrs) do
    tracker_entry
    |> cast(attrs, [:meal_time])
    |> cast_assoc(:food_entries, with: &FoodEntry.partial_changeset/2, required: true)
    |> validate_required([:meal_time])
  end
end
