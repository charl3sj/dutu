defmodule Dutu.QuotaTest do
  use Dutu.DataCase, async: true
  alias Dutu.DietTracker.Quota

  describe "validate_min_values" do
    test "throws error when per_day conflicts with per_week" do
      invalid_attrs = %{min: %Quota.Limit{per_day: 1, per_week: 3}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               per_day: {"conflicts with weekly limit", [validation: :invalid]}
             ]
    end

    test "passes validation when per_day doesn't conflict with per_week" do
      changeset = Quota.changeset(%Quota{}, %{min: %Quota.Limit{per_day: 1, per_week: 8}})
      assert changeset.valid? == true
    end

    test "throws error when per_day conflicts with per_2_weeks" do
      invalid_attrs = %{min: %Quota.Limit{per_day: 1, per_2_weeks: 3}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               per_day: {"conflicts with biweekly limit", [validation: :invalid]}
             ]
    end

    test "passes validation when per_day doesn't conflict with per_2_weeks" do
      changeset = Quota.changeset(%Quota{}, %{min: %Quota.Limit{per_day: 1, per_2_weeks: 15}})
      assert changeset.valid? == true
    end

    test "throws error when per_week conflicts with per_2_weeks" do
      invalid_attrs = %{min: %Quota.Limit{per_week: 1, per_2_weeks: 1}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               per_week: {"conflicts with biweekly limit", [validation: :invalid]}
             ]
    end

    test "passes validation when per_week doesn't conflict with per_2_weeks" do
      changeset = Quota.changeset(%Quota{}, %{min: %Quota.Limit{per_week: 1, per_2_weeks: 2}})
      assert changeset.valid? == true
    end
  end

  describe "validate_min_max_values" do
    test "throws error when min per_day value is greater than max per_day" do
      invalid_attrs = %{min: %Quota.Limit{per_day: 2}, max: %Quota.Limit{per_day: 1}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               min: {"cannot be greater than max value", [validation: :invalid]}
             ]
    end

    test "passes validation when min per_day value is less than max per_day" do
      valid_attrs = %{min: %Quota.Limit{per_day: 1}, max: %Quota.Limit{per_day: 2}}
      changeset = Quota.changeset(%Quota{}, valid_attrs)
      assert changeset.valid? == true
    end

    test "throws error when min per_week value is greater than max per_week" do
      invalid_attrs = %{min: %Quota.Limit{per_week: 2}, max: %Quota.Limit{per_week: 1}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               min: {"cannot be greater than max value", [validation: :invalid]}
             ]
    end

    test "passes validation when min per_week value is less than max per_week" do
      valid_attrs = %{min: %Quota.Limit{per_week: 1}, max: %Quota.Limit{per_week: 2}}
      changeset = Quota.changeset(%Quota{}, valid_attrs)
      assert changeset.valid? == true
    end

    test "throws error when min per_2_weeks value is greater than max per_2_weeks" do
      invalid_attrs = %{min: %Quota.Limit{per_2_weeks: 2}, max: %Quota.Limit{per_2_weeks: 1}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               min: {"cannot be greater than max value", [validation: :invalid]}
             ]
    end

    test "passes validation when min per_2_weeks value is less than max per_2_weeks" do
      valid_attrs = %{min: %Quota.Limit{per_2_weeks: 1}, max: %Quota.Limit{per_2_weeks: 2}}
      changeset = Quota.changeset(%Quota{}, valid_attrs)
      assert changeset.valid? == true
    end

    test "throws error when max per_week conflicts with min per_day value" do
      invalid_attrs = %{min: %Quota.Limit{per_day: 1}, max: %Quota.Limit{per_week: 4}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               max: {"max per_week conflicts with minimum per_day value", [validation: :invalid]}
             ]
    end

    test "passes validation when max per_week doesn't conflict with min per_day value" do
      changeset =
        Quota.changeset(%Quota{}, %{min: %Quota.Limit{per_day: 1}, max: %Quota.Limit{per_week: 8}})

      assert changeset.valid? == true
    end

    test "throws error when max per_2_weeks conflicts with min per_day value" do
      invalid_attrs = %{min: %Quota.Limit{per_day: 1}, max: %Quota.Limit{per_2_weeks: 4}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               max:
                 {"max per_2_weeks conflicts with minimum per_day value", [validation: :invalid]}
             ]
    end

    test "passes validation when max per_2_weeks doesn't conflict with min per_day value" do
      changeset =
        Quota.changeset(%Quota{}, %{
          min: %Quota.Limit{per_day: 1},
          max: %Quota.Limit{per_2_weeks: 14}
        })

      assert changeset.valid? == true
    end

    test "throws error when max per_2_weeks conflicts with min per_week value" do
      invalid_attrs = %{min: %Quota.Limit{per_week: 3}, max: %Quota.Limit{per_2_weeks: 4}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               max:
                 {"max per_2_weeks conflicts with minimum per_week value", [validation: :invalid]}
             ]
    end

    test "passes validation when max per_2_weeks doesn't conflict with min per_week value" do
      changeset =
        Quota.changeset(%Quota{}, %{
          min: %Quota.Limit{per_week: 3},
          max: %Quota.Limit{per_2_weeks: 8}
        })

      assert changeset.valid? == true
    end

    test "passes validation when ALL values are set and within appropriate limits" do
      changeset =
        Quota.changeset(%Quota{}, %{
          min: %Quota.Limit{per_day: 1, per_week: 8, per_2_weeks: 18},
          max: %Quota.Limit{per_day: 3, per_week: 10, per_2_weeks: 20}
        })

      assert changeset.valid? == true
    end
  end
end

defmodule Dutu.QuotaTest.LimitTest do
  use Dutu.DataCase, async: true
  alias Dutu.DietTracker.Quota.Limit

  describe "changeset/2" do
    test "is valid for valid values" do
      valid_attrs_1 = %{per_day: 1, per_week: nil, per_2_weeks: nil}
      valid_attrs_2 = %{per_day: nil, per_week: 2, per_2_weeks: nil}
      valid_attrs_3 = %{per_day: nil, per_week: nil, per_2_weeks: 3}

      changeset = Limit.changeset(%Limit{}, valid_attrs_1)
      assert changeset.valid? == true

      changeset = Limit.changeset(%Limit{}, valid_attrs_2)
      assert changeset.valid? == true

      changeset = Limit.changeset(%Limit{}, valid_attrs_3)
      assert changeset.valid? == true

      valid_attrs_4 = %{per_day: 1, per_week: 2, per_2_weeks: 3}
      changeset = Limit.changeset(%Limit{}, valid_attrs_4)
      assert changeset.valid? == true
    end
  end
end
