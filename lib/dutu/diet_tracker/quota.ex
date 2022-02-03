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
    %Limit{per_day: per_day, per_week: per_week, per_month: per_month} =
      case get_field(changeset, :min) do
        nil -> %Limit{}
        field -> field
      end

    cond do
      per_day != nil && per_week != nil && per_day * 7 > per_week ->
        add_error(changeset, :min, "daily limit conflicts with weekly limit", validation: :invalid)

      per_day != nil && per_month != nil && per_day * 30 > per_month ->
        add_error(changeset, :min, "daily limit conflicts with monthly limit",
          validation: :invalid
        )

      per_week != nil && per_month != nil && per_week * 4 > per_month ->
        add_error(changeset, :min, "weekly limit conflicts with monthly limit",
          validation: :invalid
        )

      true ->
        changeset
    end
  end

  defp validate_min_max_values_dont_conflict(changeset) do
    %Limit{per_day: min_per_day, per_week: min_per_week, per_month: min_per_month} =
      case get_field(changeset, :min) do
        nil -> %Limit{}
        field -> field
      end

    %Limit{per_day: max_per_day, per_week: max_per_week, per_month: max_per_month} =
      case get_field(changeset, :max) do
        nil -> %Limit{}
        field -> field
      end

    cond do
      min_per_day != nil && max_per_day != nil && min_per_day > max_per_day ->
        add_error(changeset, :min, "min per day cannot be greater than max value",
          validation: :invalid
        )

      min_per_week != nil && max_per_week != nil && min_per_week > max_per_week ->
        add_error(changeset, :min, "min per week cannot be greater than max value",
          validation: :invalid
        )

      min_per_month != nil && max_per_month != nil && min_per_month > max_per_month ->
        add_error(changeset, :min, "min per month cannot be greater than max value",
          validation: :invalid
        )

      min_per_day != nil && max_per_week != nil && min_per_day * 7 > max_per_week ->
        add_error(
          changeset,
          :max,
          "max per week conflicts with minimum per day value",
          validation: :invalid
        )

      min_per_day != nil && max_per_month != nil && min_per_day * 30 > max_per_month ->
        add_error(
          changeset,
          :max,
          "max per month conflicts with minimum per day value",
          validation: :invalid
        )

      min_per_week != nil && max_per_month != nil && min_per_week * 4 > max_per_month ->
        add_error(
          changeset,
          :max,
          "max per month conflicts with minimum per week value",
          validation: :invalid
        )

      true ->
        changeset
    end
  end
end
