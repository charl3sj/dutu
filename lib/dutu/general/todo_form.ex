defmodule Dutu.General.TodoForm do
	use Ecto.Schema
	import Ecto.Changeset
	use Dutu.DateHelpers
	alias Dutu.General.Todo
	alias Dutu.General.TodoForm

	embedded_schema do
		field :title, :string
		field :date_type, :string
		field :due_date, :date
		field :start_date, :date
		field :end_date, :date
	end

	def changeset(form, attrs \\ %{}) do
		form
    |> cast(attrs, [:title, :date_type, :due_date, :start_date, :end_date])
    |> validate_required([:title])
		|> validate_due_date_required_if_exact
		|> validate_start_date_required_if_daterange
		|> validate_end_date_required_if_daterange
	end

	defp validate_due_date_required_if_exact(changeset) do
		due_date = get_field(changeset, :due_date)
		if get_field(changeset, :date_type) == @due_date_types.on and (!due_date or due_date == "") do
				add_error(changeset, :due_date, "is required", [validation: :required])
		else
			changeset
		end
	end

	defp validate_start_date_required_if_daterange(changeset) do
		start_date = get_field(changeset, :start_date)
		if get_field(changeset, :date_type) == @due_date_types.between and (!start_date or start_date == "") do
			add_error(changeset, :start_date, "is required", [validation: :required])
		else
			changeset
		end
	end

	defp validate_end_date_required_if_daterange(changeset) do
		end_date = get_field(changeset, :end_date)
		if get_field(changeset, :date_type) == @due_date_types.between and (!end_date or end_date == "") do
			add_error(changeset, :end_date, "is required", [validation: :required])
		else
			changeset
		end
	end

	@spec to_todo_params(form :: TodoForm) :: :map
	def to_todo_params(%TodoForm{title: title, due_date: due_date, date_type: date_type}) when date_type == @due_date_types.on do
		%{
			title: title,
			due_date: due_date,
      date_attrs: %{type: @due_date_types.on},
		  approx_due_date: nil
		}
	end

	def to_todo_params(%TodoForm{title: title, start_date: start_date, end_date: end_date, date_type: date_type}) when date_type == @due_date_types.between do
		%{
			title: title,
			approx_due_date: [start_date, end_date],
			date_attrs: %{type: date_type},
			due_date: nil
		}
	end

	def to_todo_params(%TodoForm{title: title}) do
		%{title: title}
	end


	@spec from_todo(todo :: Todo) :: TodoForm
	def from_todo(%Todo{due_date: due_date} = todo) when due_date != nil do
		%TodoForm{
			title: todo.title,
			due_date: due_date,
			date_type: @due_date_types.on
		}
	end

	def from_todo(%Todo{approx_due_date: approx_due_date} = todo) when approx_due_date != nil do
		[lower, upper] = approx_due_date
		%TodoForm{
			title: todo.title,
			start_date: lower,
			end_date: upper,
			date_type: @due_date_types.between
		}
  end

	def from_todo(%Todo{due_date: nil, approx_due_date: nil} = todo) do
		%TodoForm{
			title: todo.title
		}
	end
end