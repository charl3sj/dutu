defmodule Dutu.DateRange do
	@moduledoc """
	  Custom Ecto type definition for Postgres' range (date) type.

	"""

	use Ecto.Type

	@type lower :: Date
	@type upper :: Date

	def type, do: :daterange

	def cast([lower, upper]) do
		{:ok, [lower, upper]}
	end

	def cast(_), do: :error

	def dump([lower, upper]) do
		{:ok, %Postgrex.Range{lower: lower, upper: upper}}
	end

	def dump(_), do: :error

	@doc """
	  Postgrex stores `%Postgrex.Range{lower: ~D[2022-01-01], lower_inclusive: true,
	                                   upper: ~D[2022-01-05], upper_inclusive: true}`
	  as `[2022-01-01,2022-01-06)` <-- i.e. with upper bound increased by 1 and closed by
	  parentheses instead of `[2022-01-01,2022-01-05]` <-- closed by brackets in the db.
	  So decrement upper bound by 1 while loading, for dutu's use-case.
	"""
	def load(%Postgrex.Range{lower: lower, upper: upper}) when upper in [:unbound, nil] do
		{:ok, %{lower: lower, upper: nil}}
	end

	def load(%Postgrex.Range{lower: lower, upper: upper}) do
		case {lower, upper} do
			{:unbound, upper} -> {:ok, %{lower: nil, upper: Date.add(upper, -1)}}
			{nil, upper} -> {:ok, %{lower: nil, upper: Date.add(upper, -1)}}
			{lower, upper} -> {:ok, %{lower: lower, upper: Date.add(upper, -1)}}
		end
	end
end
