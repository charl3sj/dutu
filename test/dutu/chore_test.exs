defmodule Dutu.ChoreTest do
	use Dutu.DataCase, async: true

	alias Dutu.General
	alias Dutu.General.Chore

	@daily_frequency_chore %{title: "some title", rrule: %{"frequency" => "daily", "interval" => 10}}
	@weekly_frequency_chore %{title: "some title", rrule: %{"frequency" => "weekly", "days_of_week" => "Sun, Wed"}}

	describe "recurs_every_x_days?/1" do
		test "returns true when daily frequency" do
			{:ok, chore} = General.create_chore(@daily_frequency_chore)
			assert Chore.recurs_every_x_days?(chore) == true
		end

		test "returns false when weekly frequency" do
			{:ok, chore} = General.create_chore(@weekly_frequency_chore)
			assert Chore.recurs_every_x_days?(chore) == false
		end
	end

	describe "recurs_every_week?/1" do
		test "returns false when daily frequency" do
			{:ok, chore} = General.create_chore(@daily_frequency_chore)
			assert Chore.recurs_every_week?(chore) == false
		end

		test "returns true when weekly frequency" do
			{:ok, chore} = General.create_chore(@weekly_frequency_chore)
			assert Chore.recurs_every_week?(chore) == true
		end
	end

	describe "recurs_on_date?/1" do
		test "is false for days it doesn't occur (daily freq)" do
			{:ok, every_3_days} = General.create_chore(%{title: "some title", rrule: %{"frequency" => "daily", "interval" => 3}, last_done_at: ~N"2022-01-08 11:00:00"})
			assert Chore.recurs_on_date?(every_3_days, ~D"2022-01-09") == false
			assert Chore.recurs_on_date?(every_3_days, ~D"2022-01-10") == false
		end

		test "is true for days it occurs (daily freq)" do
			{:ok, every_3_days} = General.create_chore(%{title: "some title", rrule: %{"frequency" => "daily", "interval" => 3}, last_done_at: ~N"2022-01-08 11:00:00"})
			assert Chore.recurs_on_date?(every_3_days, ~D"2022-01-11") == true
			assert Chore.recurs_on_date?(every_3_days, ~D"2022-01-12") == false
		end

		test "is false for days it doesn't occur (weekly freq)" do
			{:ok, every_sun_wed} = General.create_chore(%{title: "some title", rrule: %{"frequency" => "weekly", "days_of_week" => "Sun, Wed"}, last_done_at: ~N"2022-01-09 11:00:00"})
			assert Chore.recurs_on_date?(every_sun_wed, ~D"2022-01-11") == false # tue
			assert Chore.recurs_on_date?(every_sun_wed, ~D"2022-01-13") == false # thu
		end

		test "is true for days it occurs (weekly freq)" do
			{:ok, every_sun_wed} = General.create_chore(%{title: "some title", rrule: %{"frequency" => "weekly", "days_of_week" => "Sun, Wed"}, last_done_at: ~N"2022-01-09 11:00:00"})
			assert Chore.recurs_on_date?(every_sun_wed, ~D"2022-01-12") == true # wed
			assert Chore.recurs_on_date?(every_sun_wed, ~D"2022-01-16") == true # sun
		end
	end

	describe "due_on_date?/1" do
		test "is false for days when it isn't due (daily freq)" do
			{:ok, every_3_days} = General.create_chore(%{title: "some title", rrule: %{"frequency" => "daily", "interval" => 3}, last_done_at: ~N"2022-01-08 11:00:00"})
			assert Chore.due_on_date?(every_3_days, ~D"2022-01-09") == false
			assert Chore.due_on_date?(every_3_days, ~D"2022-01-10") == false
		end

		test "is true for days when it is due (daily freq)" do
			{:ok, every_3_days} = General.create_chore(%{title: "some title", rrule: %{"frequency" => "daily", "interval" => 3}, last_done_at: ~N"2022-01-08 11:00:00"})
			assert Chore.due_on_date?(every_3_days, ~D"2022-01-11") == true
			assert Chore.due_on_date?(every_3_days, ~D"2022-01-12") == true # due from 8th Jan + interval 3 = 11th __onwards__
			assert Chore.due_on_date?(every_3_days, ~D"2022-01-13") == true # due from 8th Jan + interval 3 = 11th __onwards__
		end

		test "is false for days when it isn't due (weekly freq)" do
			{:ok, every_sun_wed} = General.create_chore(%{title: "some title", rrule: %{"frequency" => "weekly", "days_of_week" => "Sun, Wed"}, last_done_at: ~N"2022-01-09 11:00:00"})
			assert Chore.due_on_date?(every_sun_wed, ~D"2022-01-11") == false # tue
			assert Chore.due_on_date?(every_sun_wed, ~D"2022-01-13") == false # thu
			assert Chore.due_on_date?(every_sun_wed, ~D"2022-01-17") == false # mon
			assert Chore.due_on_date?(every_sun_wed, ~D"2022-01-21") == false # fri
		end

		test "is true for days when it is due (weekly freq)" do
			{:ok, every_sun_wed} = General.create_chore(%{title: "some title", rrule: %{"frequency" => "weekly", "days_of_week" => "Sun, Wed"}, last_done_at: ~N"2022-01-09 11:00:00"})
			assert Chore.due_on_date?(every_sun_wed, ~D"2022-01-04") == false # past wed
			assert Chore.due_on_date?(every_sun_wed, ~D"2022-01-12") == true # wed
			assert Chore.due_on_date?(every_sun_wed, ~D"2022-01-16") == true # sun
			assert Chore.due_on_date?(every_sun_wed, ~D"2022-01-19") == true # wed
			assert Chore.due_on_date?(every_sun_wed, ~D"2022-01-23") == true # sun
		end
	end

end