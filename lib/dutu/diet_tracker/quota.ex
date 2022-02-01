defmodule Dutu.DietTracker.Quota do
  use Ecto.Schema
  import Ecto.Changeset

  import Dutu.Utils, only: [ensure_map: 1]
  alias Dutu.DietTracker.Quota.Limit

  @primary_key false
  embedded_schema do
    embeds_one :min, Limit, on_replace: :delete
    embeds_one :max, Limit, on_replace: :delete
  end

  @doc false
  def changeset(quota, attrs) do
    quota
    |> cast(ensure_map(attrs), [])
    |> cast_embed(:min)
    |> cast_embed(:max)
    |> validate_min_values
    |> validate_min_max_values_dont_conflict
  end

  defp validate_min_values(changeset) do
    %Limit{per_day: per_day, per_week: per_week, per_2_weeks: per_2_weeks} =
      case get_field(changeset, :min) do
        nil -> %Limit{}
        field -> field
      end

    cond do
      per_day != nil && per_week != nil && per_day * 7 > per_week ->
        add_error(changeset, :per_day, "conflicts with weekly limit", validation: :invalid)

      per_day != nil && per_2_weeks != nil && per_day * 14 > per_2_weeks ->
        add_error(changeset, :per_day, "conflicts with biweekly limit", validation: :invalid)

      per_week != nil && per_2_weeks != nil && per_week * 2 > per_2_weeks ->
        add_error(changeset, :per_week, "conflicts with biweekly limit", validation: :invalid)

      true ->
        changeset
    end
  end

  defp validate_min_max_values_dont_conflict(changeset) do
    %Limit{per_day: min_per_day, per_week: min_per_week, per_2_weeks: min_per_2_weeks} =
      case get_field(changeset, :min) do
        nil -> %Limit{}
        field -> field
      end

    %Limit{per_day: max_per_day, per_week: max_per_week, per_2_weeks: max_per_2_weeks} =
      case get_field(changeset, :max) do
        nil -> %Limit{}
        field -> field
      end

    cond do
      min_per_day != nil && max_per_day != nil && min_per_day > max_per_day ->
        add_error(changeset, :min, "cannot be greater than max value", validation: :invalid)

      min_per_week != nil && max_per_week != nil && min_per_week > max_per_week ->
        add_error(changeset, :min, "cannot be greater than max value", validation: :invalid)

      min_per_2_weeks != nil && max_per_2_weeks != nil && min_per_2_weeks > max_per_2_weeks ->
        add_error(changeset, :min, "cannot be greater than max value", validation: :invalid)

      min_per_day != nil && max_per_week != nil && min_per_day * 7 > max_per_week ->
        add_error(
          changeset,
          :max,
          "max per_week conflicts with minimum per_day value",
          validation: :invalid
        )

      min_per_day != nil && max_per_2_weeks != nil && min_per_day * 14 > max_per_2_weeks ->
        add_error(
          changeset,
          :max,
          "max per_2_weeks conflicts with minimum per_day value",
          validation: :invalid
        )

      min_per_week != nil && max_per_2_weeks != nil && min_per_week * 2 > max_per_2_weeks ->
        add_error(
          changeset,
          :max,
          "max per_2_weeks conflicts with minimum per_week value",
          validation: :invalid
        )

      true ->
        changeset
    end
  end
end
