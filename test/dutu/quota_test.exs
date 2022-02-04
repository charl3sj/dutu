defmodule Dutu.QuotaTest do
  use Dutu.DataCase, async: true
  alias Dutu.DietTracker.Quota

  describe "validate_min_limits" do
    test "throws error when per_day conflicts with per_week" do
      invalid_attrs = %{min: %Quota.Limit{per_day: 1, per_week: 3}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               min: {"daily limit conflicts with weekly limit", [validation: :invalid]}
             ]
    end

    test "passes validation when per_day doesn't conflict with per_week" do
      changeset = Quota.changeset(%Quota{}, %{min: %Quota.Limit{per_day: 1, per_week: 8}})
      assert changeset.valid? == true
    end

    test "throws error when per_day conflicts with per_month" do
      invalid_attrs = %{min: %Quota.Limit{per_day: 1, per_month: 3}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               min: {"daily limit conflicts with monthly limit", [validation: :invalid]}
             ]
    end

    test "passes validation when per_day doesn't conflict with per_month" do
      changeset = Quota.changeset(%Quota{}, %{min: %Quota.Limit{per_day: 1, per_month: 31}})
      assert changeset.valid? == true
    end

    test "throws error when per_week conflicts with per_month" do
      invalid_attrs = %{min: %Quota.Limit{per_week: 1, per_month: 1}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               min: {"weekly limit conflicts with monthly limit", [validation: :invalid]}
             ]
    end

    test "passes validation when per_week doesn't conflict with per_month" do
      changeset = Quota.changeset(%Quota{}, %{min: %Quota.Limit{per_week: 1, per_month: 5}})
      assert changeset.valid? == true
    end
  end

  describe "validate_min_max_values" do
    test "throws error when min per_day value is greater than max per_day" do
      invalid_attrs = %{min: %Quota.Limit{per_day: 2}, max: %Quota.Limit{per_day: 1}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               min: {"min per day cannot be greater than max value", [validation: :invalid]}
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
               min: {"min per week cannot be greater than max value", [validation: :invalid]}
             ]
    end

    test "passes validation when min per_week value is less than max per_week" do
      valid_attrs = %{min: %Quota.Limit{per_week: 1}, max: %Quota.Limit{per_week: 2}}
      changeset = Quota.changeset(%Quota{}, valid_attrs)
      assert changeset.valid? == true
    end

    test "throws error when min per_month value is greater than max per_month" do
      invalid_attrs = %{min: %Quota.Limit{per_month: 2}, max: %Quota.Limit{per_month: 1}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               min: {"min per month cannot be greater than max value", [validation: :invalid]}
             ]
    end

    test "passes validation when min per_month value is less than max per_month" do
      valid_attrs = %{min: %Quota.Limit{per_month: 1}, max: %Quota.Limit{per_month: 2}}
      changeset = Quota.changeset(%Quota{}, valid_attrs)
      assert changeset.valid? == true
    end

    test "throws error when max per_week conflicts with min per_day value" do
      invalid_attrs = %{min: %Quota.Limit{per_day: 1}, max: %Quota.Limit{per_week: 4}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               max: {"max per week conflicts with minimum per day value", [validation: :invalid]}
             ]
    end

    test "passes validation when max per_week doesn't conflict with min per_day value" do
      changeset =
        Quota.changeset(%Quota{}, %{min: %Quota.Limit{per_day: 1}, max: %Quota.Limit{per_week: 8}})

      assert changeset.valid? == true
    end

    test "throws error when max per_month conflicts with min per_day value" do
      invalid_attrs = %{min: %Quota.Limit{per_day: 1}, max: %Quota.Limit{per_month: 4}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               max: {"max per month conflicts with minimum per day value", [validation: :invalid]}
             ]
    end

    test "passes validation when max per_month doesn't conflict with min per_day value" do
      changeset =
        Quota.changeset(%Quota{}, %{
          min: %Quota.Limit{per_day: 1},
          max: %Quota.Limit{per_month: 31}
        })

      assert changeset.valid? == true
    end

    test "throws error when max per_month conflicts with min per_week value" do
      invalid_attrs = %{min: %Quota.Limit{per_week: 3}, max: %Quota.Limit{per_month: 4}}
      changeset = Quota.changeset(%Quota{}, invalid_attrs)
      assert changeset.valid? == false

      assert changeset.errors == [
               max:
                 {"max per month conflicts with minimum per week value", [validation: :invalid]}
             ]
    end

    test "passes validation when max per_month doesn't conflict with min per_week value" do
      changeset =
        Quota.changeset(%Quota{}, %{
          min: %Quota.Limit{per_week: 3},
          max: %Quota.Limit{per_month: 13}
        })

      assert changeset.valid? == true
    end

    test "passes validation when ALL values are set and within appropriate limits" do
      changeset =
        Quota.changeset(%Quota{}, %{
          min: %Quota.Limit{per_day: 1, per_week: 8, per_month: 35},
          max: %Quota.Limit{per_day: 3, per_week: 10, per_month: 40}
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
      valid_attrs_1 = %{per_day: 1, per_week: nil, per_month: nil}
      valid_attrs_2 = %{per_day: nil, per_week: 2, per_month: nil}
      valid_attrs_3 = %{per_day: nil, per_week: nil, per_month: 3}

      changeset = Limit.changeset(%Limit{}, valid_attrs_1)
      assert changeset.valid? == true

      changeset = Limit.changeset(%Limit{}, valid_attrs_2)
      assert changeset.valid? == true

      changeset = Limit.changeset(%Limit{}, valid_attrs_3)
      assert changeset.valid? == true

      valid_attrs_4 = %{per_day: 1, per_week: 2, per_month: 3}
      changeset = Limit.changeset(%Limit{}, valid_attrs_4)
      assert changeset.valid? == true
    end
  end
end
