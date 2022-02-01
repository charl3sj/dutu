defmodule Dutu.DietTracker.Quota.Limit do
  use Ecto.Schema
  import Ecto.Changeset

  import Dutu.Utils, only: [ensure_map: 1]

  @primary_key false
  embedded_schema do
    field :per_day, :integer
    field :per_week, :integer
    field :per_2_weeks, :integer
  end

  def changeset(limit, attrs) do
    limit
    |> cast(ensure_map(attrs), [:per_day, :per_week, :per_2_weeks])
    |> validate_per_day
    |> validate_per_week
  end

  defp validate_per_day(changeset) do
    per_day = get_field(changeset, :per_day)
    per_week = get_field(changeset, :per_week)
    per_2_weeks = get_field(changeset, :per_2_weeks)

    cond do
      per_day != nil && per_week != nil && per_day > per_week ->
        add_error(changeset, :per_day, "cannot be greater than weekly limit", validation: :invalid)

      per_day != nil && per_2_weeks != nil && per_day > per_2_weeks ->
        add_error(changeset, :per_day, "cannot be greater than biweekly limit",
          validation: :invalid
        )

      true ->
        changeset
    end
  end

  defp validate_per_week(changeset) do
    per_week = get_field(changeset, :per_week)
    per_2_weeks = get_field(changeset, :per_2_weeks)

    cond do
      per_week != nil && per_2_weeks != nil && per_week > per_2_weeks ->
        add_error(changeset, :per_week, "cannot be greater than biweekly limit",
          validation: :invalid
        )

      true ->
        changeset
    end
  end
end
