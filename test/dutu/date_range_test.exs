defmodule Dutu.DateRangeTest do
	use ExUnit.Case
	import Dutu.DateRange

	test "type == :daterange" do
		assert type() == :daterange
	end

	test "cast" do
		assert cast([~D"2022-01-01", ~D"2022-01-05"]) == {:ok, [~D"2022-01-01", ~D"2022-01-05"]}
		assert cast([nil, ~D"2022-01-01"]) == {:ok, [nil, ~D"2022-01-01"]}
		assert cast([~D"2022-01-01", nil]) == {:ok, [~D"2022-01-01", nil]}
	end

	test "dump" do
		assert dump([~D"2022-01-01", ~D"2022-01-05"]) == {
			       :ok,
			       %Postgrex.Range{
				       lower: ~D[2022-01-01],
				       lower_inclusive: true,
				       upper: ~D[2022-01-05],
				       upper_inclusive: true
			       }
		       },
		       "lower and upper bounds set to support 'between X and Y date' scenario"

		assert dump([nil, ~D"2022-01-01"]) == {
			       :ok,
			       %Postgrex.Range{
				       lower: nil,
				       lower_inclusive: true,
				       upper: ~D[2022-01-01],
				       upper_inclusive: true
			       }
		       },
		       "only upper bound specified to support 'before X date' scenario"

		assert dump([~D"2022-01-01", nil]) == {
			       :ok,
			       %Postgrex.Range{
				       lower: ~D[2022-01-01],
				       lower_inclusive: true,
				       upper: nil,
				       upper_inclusive: true
			       }
		       },
		       "only lower bound specified to support 'after X date' scenario"
	end

	test "load" do
		assert load(
			       %Postgrex.Range{
				       lower: ~D[2022-01-01],
				       upper: ~D[2022-01-05],
			       }
		       ) == {:ok, [~D"2022-01-01", ~D"2022-01-04"]},
		       "lower and upper bounds set"

		assert load(
			       %Postgrex.Range{
				       lower: ~D[2022-01-01]
			       }
		       ) == {:ok, [~D"2022-01-01", nil]},
		       "upper bound unspecified"

		assert load(
			       %Postgrex.Range{
				       upper: ~D[2022-01-02]
			       }
		       ) == {:ok, [nil, ~D"2022-01-01"]},
		       "lower bound unspecified"
	end
end