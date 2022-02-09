defmodule Dutu.DietTrackerTest do
  use Dutu.DataCase

  alias Dutu.DietTracker
  import Dutu.DietTrackerFixtures

  describe "| categories |" do
    alias Dutu.DietTracker.Category

    @invalid_attrs %{name: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert DietTracker.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert DietTracker.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Category{} = category} = DietTracker.create_category(valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DietTracker.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Category{} = category} = DietTracker.update_category(category, update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = DietTracker.update_category(category, @invalid_attrs)
      assert category == DietTracker.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = DietTracker.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> DietTracker.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = DietTracker.change_category(category)
    end
  end

  describe "| foods |" do
    alias Dutu.DietTracker.Food

    @invalid_attrs %{name: nil}

    test "list_foods/0 returns all foods" do
      food = food_fixture()

      assert DietTracker.list_foods()
             |> Enum.map(&Map.delete(&1, :category)) == [Map.delete(food, :category)]
    end

    test "get_food!/1 returns the food with given id" do
      food = food_fixture()
      assert DietTracker.get_food!(food.id) == food
    end

    test "create_food/1 with valid data creates a food" do
      category = category_fixture()
      valid_attrs = %{name: "some name", category_id: category.id}

      assert {:ok, %Food{} = food} = DietTracker.create_food(valid_attrs)
      assert food.name == "some name"
      assert food.category_id == category.id
    end

    test "create_food/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DietTracker.create_food(@invalid_attrs)
    end

    test "update_food/2 with valid data updates the food" do
      food = food_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Food{} = food} = DietTracker.update_food(food, update_attrs)
      assert food.name == "some updated name"
    end

    test "update_food/2 with invalid data returns error changeset" do
      food = food_fixture()
      assert {:error, %Ecto.Changeset{}} = DietTracker.update_food(food, @invalid_attrs)
      assert food == DietTracker.get_food!(food.id)
    end

    test "delete_food/1 deletes the food" do
      food = food_fixture()
      assert {:ok, %Food{}} = DietTracker.delete_food(food)
      assert_raise Ecto.NoResultsError, fn -> DietTracker.get_food!(food.id) end
    end

    test "change_food/1 returns a food changeset" do
      food = food_fixture()
      assert %Ecto.Changeset{} = DietTracker.change_food(food)
    end
  end

  describe "| tracker_entries |" do
    alias Dutu.DietTracker.TrackerEntry

    test "create_tracker_entry/1 with valid data creates an entry" do
      food_1 = food_fixture(%{name: "food 1", category_name: "cat 1"})
      food_2 = food_fixture(%{name: "food 2", category_name: "cat 2"})

      valid_attrs = %{
        meal_time: ~N"2022-03-14 13:44:23",
        food_entries: [%{food_id: food_1.id}, %{food_id: food_2.id}]
      }

      assert {:ok, %TrackerEntry{} = entry} = DietTracker.create_tracker_entry(valid_attrs)
      assert entry.meal_time == ~N"2022-03-14 13:44:23"

      [food_entry_1, food_entry_2] =
        entry.food_entries
        |> Enum.map(&Dutu.Repo.preload(&1, :food))

      assert food_entry_1.food.name == "food 1"
      assert food_entry_2.food.name == "food 2"
    end

    test "create_tracker_entry/1 with invalid data returns error changeset" do
      without_food_entries = %{meal_time: ~N"2022-03-14 13:44:23", food_entries: []}

      assert {:error, %Ecto.Changeset{} = changeset} =
               DietTracker.create_tracker_entry(without_food_entries)

      assert changeset.errors == [food_entries: {"can't be blank", [validation: :required]}]

      without_meal_time = %{meal_time: nil, food_entries: [%{food_id: 1}, %{food_id: 2}]}

      assert {:error, %Ecto.Changeset{} = changeset} =
               DietTracker.create_tracker_entry(without_meal_time)

      assert changeset.errors == [meal_time: {"can't be blank", [validation: :required]}]
    end

    test "delete_tracker_entry/1 deletes entry with given `id`" do
      food = food_fixture()

      {:ok, %TrackerEntry{} = entry} =
        DietTracker.create_tracker_entry(%{
          meal_time: ~N"2022-03-14 13:44:23",
          food_entries: [%{food_id: food.id}]
        })

      assert {:ok, %TrackerEntry{}} = DietTracker.delete_tracker_entry(entry.id)
      assert_raise Ecto.NoResultsError, fn -> DietTracker.get_tracker_entry!(entry.id) end
    end

    test "delete_tracker_entry/1 returns :error if entry with given `id` doesn't exist" do
      assert {:error, :not_found, error_msg} = DietTracker.delete_tracker_entry(9999)
      assert error_msg == "Entry with id 9999 not found"
    end
  end
end
