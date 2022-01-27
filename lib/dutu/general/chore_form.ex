defmodule Dutu.General.ChoreForm do
  use Ecto.Schema
  import Ecto.Changeset
  use Dutu.DateHelpers
  alias Dutu.General.Chore
  alias Dutu.General.ChoreForm

  embedded_schema do
    field :title, :string
    field :frequency, :string
    field :interval, :integer
    field :days_of_week, :string
  end

  def changeset(form, attrs \\ %{}) do
    form
    |> cast(attrs, [:title, :frequency, :interval, :days_of_week])
    |> validate_required([:title, :frequency])
    |> validate_interval_required_if_daily
    |> validate_days_of_week_required_if_weekly
  end

  defp validate_interval_required_if_daily(changeset) do
    interval = get_field(changeset, :interval)

    if get_field(changeset, :frequency) == @recurrence_frequency.daily and
         (!interval or interval == "") do
      add_error(changeset, :interval, "is required", validation: :required)
    else
      changeset
    end
  end

  defp validate_days_of_week_required_if_weekly(changeset) do
    days_of_week = get_field(changeset, :days_of_week)

    if get_field(changeset, :frequency) == @recurrence_frequency.weekly and
         (!days_of_week or days_of_week == "") do
      add_error(changeset, :days_of_week, "is required", validation: :required)
    else
      changeset
    end
  end

  @spec to_chore_params(form :: ChoreForm) :: :map
  def to_chore_params(%ChoreForm{title: title, frequency: frequency, interval: interval})
      when interval != nil do
    %{
      title: title,
      rrule: %{
        frequency: frequency,
        interval: interval
      }
    }
  end

  def to_chore_params(%ChoreForm{title: title, frequency: frequency, days_of_week: days_of_week})
      when days_of_week != nil do
    %{
      title: title,
      rrule: %{
        frequency: frequency,
        days_of_week: days_of_week
      }
    }
  end

  @spec from_chore(chore :: Chore) :: ChoreForm
  def from_chore(
        %Chore{
          rrule: %{
            "days_of_week" => days_of_week,
            "frequency" => frequency
          }
        } = chore
      )
      when days_of_week != nil do
    %ChoreForm{
      title: chore.title,
      frequency: frequency,
      days_of_week: days_of_week
    }
  end

  def from_chore(
        %Chore{
          rrule: %{
            "interval" => interval,
            "frequency" => frequency
          }
        } = chore
      )
      when interval != nil do
    %ChoreForm{
      title: chore.title,
      frequency: frequency,
      interval: interval
    }
  end
end
