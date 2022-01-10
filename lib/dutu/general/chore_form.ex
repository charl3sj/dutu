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
	end

	@spec to_chore_params(form :: ChoreForm) :: :map
	def to_chore_params(%ChoreForm{title: title, frequency: frequency, interval: interval}) when interval != nil do
		%{
			title: title,
			rrule: %{
				frequency: frequency,
				interval: interval
			}
		}
	end

	def to_chore_params(%ChoreForm{title: title, frequency: frequency, days_of_week: days_of_week}) when days_of_week != nil do
		%{
			title: title,
			rrule: %{
				frequency: frequency,
				days_of_week: days_of_week
			}
		}
	end

	@spec from_chore(chore :: Chore) :: ChoreForm
	def from_chore(%Chore{rrule: %{"days_of_week" => days_of_week, "frequency" => frequency}} = chore) when days_of_week != nil do
		%ChoreForm{
			title: chore.title,
			frequency: frequency,
      days_of_week: days_of_week
		}
	end

	def from_chore(%Chore{rrule: %{"interval" => interval, "frequency" => frequency}} = chore) when interval != nil do
		%ChoreForm{
			title: chore.title,
			frequency: frequency,
			interval: interval
		}
  end

end