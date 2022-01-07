defmodule Dutu.General.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  import Timex
  import Circadiem.DateHelpers
  use Circadiem.DateHelpers

  alias Dutu.General.Todo

  schema "todos" do
    field :title, :string
    field :due_date, :date
    field :approx_due_date, Dutu.DateRange
    field :date_attrs, :map
    field :formatted_date, :string, virtual: true
    field :is_done, :boolean, default: false
    field :done_at, :naive_datetime
  end

  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :due_date, :approx_due_date, :date_attrs, :is_done, :done_at])
    |> validate_required([:title])
    |> check_constraint(:due_date, name: :due_date_and_approx_due_date_dont_occur_together)
    |> check_constraint(:approx_due_date, name: :due_date_and_approx_due_date_dont_occur_together)
    |> check_constraint(:approx_due_date, name: :approx_due_date_must_have_date_attrs)
    |> check_constraint(:date_attrs, name: :approx_due_date_must_have_date_attrs)
  end

  def put_formatted_date(%Todo{due_date: nil, approx_due_date: nil} = todo) do
    Map.put todo, :formatted_date, "undefined"
  end

  def put_formatted_date(%Todo{due_date: due_date, approx_due_date: nil} = todo) when due_date != nil do
    Map.put todo, :formatted_date, "#{due_date |> to_default_format}"
  end

  def put_formatted_date(%Todo{due_date: nil, approx_due_date: approx_due_date, date_attrs: %{"type" => datetype}} = todo) when approx_due_date != nil do
    [lower, upper] = approx_due_date
    cond do
      datetype == @due_date_types.after -> Map.put todo, :formatted_date, "after #{to_default_format(lower)}"
      datetype == @due_date_types.before -> Map.put todo, :formatted_date, "before #{to_default_format(upper)}"
      datetype == @due_date_types.between -> Map.put todo, :formatted_date, "between #{to_default_format(lower)} and #{to_default_format(upper)}"
    end
  end

  @doc """
  Returns a boolean indicating whether `todo` is due on a specified day

  If a todo has approx due date with only either bound set, it will be considered due if:
    - `some date` is __any__ date before upper bound
    - `some date` is __any__ date after lower bound
  """
  @spec due_on_date?(todo :: Todo, some_date :: Date) :: boolean
  def due_on_date?(todo, some_date) do
    cond do
      todo.due_date == nil and todo.approx_due_date ==  nil -> false

      todo.due_date != nil -> some_date == todo.due_date

      todo.approx_due_date != nil -> case todo.approx_due_date do
                                       [nil, upper] -> some_date <= upper
                                       [lower, nil] -> some_date >= (lower)
                                       [lower, upper] -> some_date |> between?(lower, upper, inclusive: true)
                                     end
    end
  end

  @doc """
  Returns a boolean indicating whether `todo` is due
  in the period between `from_date` and `to_date`
  """
  @spec due_between?(todo :: Todo, start :: Date, ending :: Date) :: boolean
  def due_between?(todo, start, ending) do
    cond do
      todo.due_date == nil and todo.approx_due_date ==  nil -> false
      todo.due_date == nil ->
        case todo.approx_due_date do
          [nil, upper] -> (ending |> before?(upper))
                          or upper |> between?(start, ending, inclusive: true)
          [lower, nil] -> (start |> after?(lower))
                          or lower |> between?(start, ending, inclusive: true)
          [lower, upper] -> between?(lower, start, ending, inclusive: true)
                            or between?(upper, start, ending, inclusive: true)
        end
      todo.approx_due_date == nil -> between?(todo.due_date, start, ending, inclusive: true)
    end
  end

  @doc """
  Returns a boolean indicating whether `todo` was due before `some_date`
  """
  @spec due_before?(todo :: Todo, some_date :: Date) :: boolean
  def due_before?(todo, some_date) do
    cond do
      todo.due_date == nil and todo.approx_due_date ==  nil -> false
      todo.due_date == nil ->
        case todo.approx_due_date do
          [nil, upper] -> upper |> before?(some_date)
          [_lower, nil] -> false
          [lower, upper] -> before?(lower, some_date) and before?(upper, some_date)
        end
      todo.approx_due_date == nil -> before?(todo.due_date, some_date)
    end
  end

  def due_today?(todo), do: due_on_date?(todo, today())

  def due_tomorrow?(todo), do: due_on_date?(todo, tomorrow())

  def due_this_week?(todo), do: due_between?(todo, start_of_this_week(), start_of_this_week() |> end_of_week)

  def due_this_month?(todo), do: due_between?(todo, start_of_this_month(), start_of_this_month() |> end_of_month)

  def due_this_quarter?(todo), do: due_between?(todo, start_of_this_quarter(), start_of_this_quarter() |> end_of_quarter)

  def due_this_year?(todo), do: due_between?(todo, start_of_this_year(), start_of_this_year() |> end_of_year)

  def due_date_undefined?(todo), do: todo.due_date == nil and todo.approx_due_date == nil

end
