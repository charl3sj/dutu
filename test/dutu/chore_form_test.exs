defmodule Dutu.ChoreFormTest do
  use Dutu.DataCase, async: true

  use Dutu.DateHelpers

  alias Dutu.General
  alias Dutu.General.ChoreForm

  describe "from_chore/1" do
    test "creates form for chore that recurs every x days" do
      {:ok, chore} =
        General.create_chore(%{
          title: "some title",
          rrule: %{"frequency" => @recurrence_frequency.daily, "interval" => 3}
        })

      chore_form = ChoreForm.from_chore(chore)
      assert chore_form.frequency == @recurrence_frequency.daily
      assert chore_form.interval == 3
    end

    test "creates form for chore that recurs <x, y...> days of week" do
      {:ok, chore} =
        General.create_chore(%{
          title: "some title",
          rrule: %{"frequency" => @recurrence_frequency.weekly, "days_of_week" => "Sun, Wed"}
        })

      chore_form = ChoreForm.from_chore(chore)
      assert chore_form.frequency == @recurrence_frequency.weekly
      assert chore_form.days_of_week == "Sun, Wed"
    end
  end

  describe "to_chore_params/1" do
    test "from form with frequency and interval" do
      chore_form = %ChoreForm{title: "foo", frequency: @recurrence_frequency.daily, interval: 3}
      params = ChoreForm.to_chore_params(chore_form)
      assert params.title == "foo"
      assert params.rrule.frequency == @recurrence_frequency.daily
      assert params.rrule.interval == 3
    end

    test "from form with days of week" do
      chore_form = %ChoreForm{
        title: "foo",
        frequency: @recurrence_frequency.weekly,
        days_of_week: "Mon, Fri"
      }

      params = ChoreForm.to_chore_params(chore_form)
      assert params.title == "foo"
      assert params.rrule.frequency == @recurrence_frequency.weekly
      assert params.rrule.days_of_week == "Mon, Fri"
    end
  end
end
