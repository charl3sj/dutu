defmodule Dutu.DateHelpers do
  import Timex,
    only: [
      shift: 2,
      beginning_of_week: 1,
      beginning_of_month: 1,
      beginning_of_quarter: 1,
      beginning_of_year: 1,
      end_of_quarter: 1
    ]

  def today, do: Timex.today(Application.fetch_env!(:dutu, :default_tz))
  def now, do: Timex.now(Application.fetch_env!(:dutu, :default_tz))

  def tomorrow, do: today() |> shift(days: 1)
  def start_of_this_week, do: today() |> beginning_of_week
  def start_of_this_month, do: today() |> beginning_of_month
  def start_of_this_quarter, do: today() |> beginning_of_quarter
  def start_of_this_year, do: today() |> beginning_of_year

  def start_of_next_week, do: start_of_this_week() |> shift(weeks: 1)
  def start_of_next_month, do: start_of_this_month() |> shift(months: 1)
  def start_of_next_quarter, do: today() |> end_of_quarter |> shift(days: 1)
  def start_of_next_year, do: start_of_this_year() |> shift(years: 1)

  def to_default_format(nil), do: ""
  def to_default_format(date), do: Calendar.strftime(date, "%b %d")

  defmacro __using__(_) do
    quote do
      @due_date_types %{
        on: "on",
        between: "between",
        before: "before",
        after: "after"
      }

      @recurrence_frequency %{
        daily: "daily",
        weekly: "weekly"
      }
    end
  end
end
