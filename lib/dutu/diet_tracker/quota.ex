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
    |> validate_min_limits
    |> validate_min_max_limits_dont_conflict
  end

  defp validate_min_limits(changeset) do
    case get_field(changeset, :min) do
      nil ->
        changeset

      %Limit{per_day: per_day, per_week: per_week, per_month: per_month} ->
        changeset
        |> validate_day_within_weekly_limit(per_day, per_week)
        |> validate_day_within_monthly_limit(per_day, per_month)
        |> validate_week_within_monthly_limit(per_week, per_month)
    end
  end

  defp validate_day_within_weekly_limit(changeset, per_day, per_week)
       when per_day != nil and per_week != nil do
    if per_day * 7 > per_week do
      add_error(changeset, :min, "daily limit conflicts with weekly limit", validation: :invalid)
    else
      changeset
    end
  end

  defp validate_day_within_weekly_limit(changeset, _, _) do
    changeset
  end

  defp validate_day_within_monthly_limit(changeset, per_day, per_month)
       when per_day != nil and per_month != nil do
    if per_day * 30 > per_month do
      add_error(changeset, :min, "daily limit conflicts with monthly limit", validation: :invalid)
    else
      changeset
    end
  end

  defp validate_day_within_monthly_limit(changeset, _, _) do
    changeset
  end

  defp validate_week_within_monthly_limit(changeset, per_week, per_month)
       when per_week != nil and per_month != nil do
    if per_week * 4 > per_month do
      add_error(changeset, :min, "weekly limit conflicts with monthly limit", validation: :invalid)
    else
      changeset
    end
  end

  defp validate_week_within_monthly_limit(changeset, _, _) do
    changeset
  end

  defp validate_min_max_limits_dont_conflict(changeset) do
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

    changeset
    |> validate_min_less_than_max(min_per_day, max_per_day, "per day")
    |> validate_min_less_than_max(min_per_week, max_per_week, "per week")
    |> validate_min_less_than_max(min_per_month, max_per_month, "per month")
    |> validate_day_min_within_week_max(min_per_day, max_per_week)
    |> validate_day_min_within_month_max(min_per_day, max_per_month)
    |> validate_week_min_within_month_max(min_per_week, max_per_month)
  end

  defp validate_min_less_than_max(changeset, min, max, per_what) when min != nil and max != nil do
    if min > max do
      add_error(changeset, :min, "min #{per_what} cannot be greater than max value",
        validation: :invalid
      )
    else
      changeset
    end
  end

  defp validate_min_less_than_max(changeset, _, _, _) do
    changeset
  end

  defp validate_day_min_within_week_max(changeset, min_per_day, max_per_week)
       when min_per_day != nil and max_per_week != nil do
    if min_per_day * 7 > max_per_week do
      add_error(
        changeset,
        :max,
        "max per week conflicts with minimum per day value",
        validation: :invalid
      )
    else
      changeset
    end
  end

  defp validate_day_min_within_week_max(changeset, _, _) do
    changeset
  end

  defp validate_day_min_within_month_max(changeset, min_per_day, max_per_month)
       when min_per_day != nil and max_per_month != nil do
    if min_per_day * 30 > max_per_month do
      add_error(
        changeset,
        :max,
        "max per month conflicts with minimum per day value",
        validation: :invalid
      )
    else
      changeset
    end
  end

  defp validate_day_min_within_month_max(changeset, _, _) do
    changeset
  end

  defp validate_week_min_within_month_max(changeset, min_per_week, max_per_month)
       when min_per_week != nil and max_per_month != nil do
    if min_per_week * 4 > max_per_month do
      add_error(
        changeset,
        :max,
        "max per month conflicts with minimum per week value",
        validation: :invalid
      )
    else
      changeset
    end
  end

  defp validate_week_min_within_month_max(changeset, _, _) do
    changeset
  end
end
