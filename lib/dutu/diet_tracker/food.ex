defmodule Dutu.DietTracker.Food do
  use Ecto.Schema
  import Ecto.Changeset
  alias Dutu.DietTracker.{Quota, Category}

  schema "foods" do
    field :name, :string
    belongs_to :category, Category
    embeds_one :quota, Quota, on_replace: :delete
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name, :category_id])
    |> validate_required([:name])
    |> cast_embed(:quota)
  end
end
