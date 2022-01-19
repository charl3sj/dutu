defmodule Dutu.General.Chore do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chores" do
    field :title, :string
    field :rrule, :map
    field :last_done_at, :naive_datetime
  end

  def changeset(chore, attrs) do
    chore
    |> cast(attrs, [:title, :rrule, :last_done_at])
    |> validate_required([:title, :rrule])
  end

  def recurs_every_x_days?(chore), do: chore.rrule["frequency"] == "daily"

  def recurs_every_week?(chore), do: chore.rrule["frequency"] == "weekly"

  def recurs_on_date?(chore, date) do
    last_done_at = chore.last_done_at

    if chore.rrule["frequency"] == "daily" do
      if last_done_at do
        Timex.equal?(date, Date.add(last_done_at, chore.rrule["interval"]))
      else
        true
      end
    else
      chore.rrule["days_of_week"] =~ Calendar.strftime(date, "%a")
    end
  end

  def due_on_date?(chore, as_of_date) do
    last_done_at = chore.last_done_at

    if chore.rrule["frequency"] == "daily" do
      if last_done_at do
        due_date = Date.add(last_done_at, chore.rrule["interval"])
        Timex.equal?(due_date, as_of_date) or Timex.before?(due_date, as_of_date)
      else
        true
      end
    else
      chore.rrule["days_of_week"] =~ Calendar.strftime(as_of_date, "%a") and
        if last_done_at, do: Timex.before?(last_done_at, as_of_date), else: true
    end
  end
end
