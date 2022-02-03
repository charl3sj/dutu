defmodule Dutu.DietTracker.Quota.Limit do
  use Ecto.Schema
  import Ecto.Changeset

  import Dutu.Utils, only: [ensure_map: 1]

  @primary_key false
  embedded_schema do
    field :per_day, :integer
    field :per_week, :integer
    field :per_month, :integer
  end

  def changeset(limit, attrs) do
    limit
    |> cast(ensure_map(attrs), [:per_day, :per_week, :per_month])
    |> validate_number(:per_day, greater_than: 0)
    |> validate_number(:per_week, greater_than: 0)
    |> validate_number(:per_month, greater_than: 0)
    |> validate_per_day
    |> validate_per_week
  end

  defp validate_per_day(changeset) do
    per_day = get_field(changeset, :per_day)
    per_week = get_field(changeset, :per_week)
    per_month = get_field(changeset, :per_month)

    cond do
      per_day != nil && per_week != nil && per_day > per_week ->
        add_error(changeset, :per_day, "cannot be greater than weekly limit", validation: :invalid)

      per_day != nil && per_month != nil && per_day > per_month ->
        add_error(changeset, :per_day, "cannot be greater than monthly limit",
          validation: :invalid
        )

      true ->
        changeset
    end
  end

  defp validate_per_week(changeset) do
    per_week = get_field(changeset, :per_week)
    per_month = get_field(changeset, :per_month)

    if per_week != nil && per_month != nil && per_week > per_month do
      add_error(changeset, :per_week, "cannot be greater than monthly limit",
        validation: :invalid
      )
    else
      changeset
    end
  end
end
