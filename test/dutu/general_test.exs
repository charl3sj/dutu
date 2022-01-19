defmodule Dutu.GeneralTest do
  use Dutu.DataCase, async: true

  alias Dutu.General
  alias Dutu.General.Todo
  import Dutu.GeneralFixtures

  describe "create_todo/1" do
    test "with only `title` creates a todo" do
      assert {:ok, %Todo{} = todo} = General.create_todo(%{title: "some title"})
      assert todo.title == "some title"
    end

    test "with `title` and `due_date` creates a todo" do
      valid_attrs = %{title: "some title", due_date: ~D"2022-11-03"}
      assert {:ok, %Todo{} = todo} = General.create_todo(valid_attrs)
      assert todo.title == "some title"
      assert todo.due_date == ~D"2022-11-03"
    end

    test "with no `title` fails validation" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               General.create_todo(%{due_date: ~D"2022-11-03"})

      assert changeset.errors == [title: {"can't be blank", [validation: :required]}]
    end

    test "with both `due_date` and `approx_due_date` fails constraint check" do
      valid_attrs = %{
        title: "some title",
        due_date: ~D"2022-11-03",
        approx_due_date: [~D"2022-11-03", ~D"2022-11-07"],
        date_attrs: %{}
      }

      assert {:error, %Ecto.Changeset{} = changeset} = General.create_todo(valid_attrs)

      assert changeset.errors == [
               approx_due_date:
                 {"is invalid",
                  [
                    constraint: :check,
                    constraint_name: "due_date_and_approx_due_date_dont_occur_together"
                  ]}
             ]
    end

    test "with `title` and `approx_due_date` without `date_attrs` fails constraint check" do
      invalid_attrs = %{title: "some title", approx_due_date: [~D"2022-11-03", ~D"2022-11-07"]}
      assert {:error, %Ecto.Changeset{} = changeset} = General.create_todo(invalid_attrs)

      assert changeset.errors == [
               date_attrs:
                 {"is invalid",
                  [constraint: :check, constraint_name: "approx_due_date_must_have_date_attrs"]}
             ]
    end

    test "with `title` and `approx_due_date` with `date_attrs` creates a todo" do
      valid_attrs = %{
        title: "some title",
        approx_due_date: [~D"2022-11-03", ~D"2022-11-07"],
        date_attrs: %{}
      }

      assert {:ok, %Todo{} = todo} = General.create_todo(valid_attrs)
      assert todo.title == "some title"
      assert todo.approx_due_date == [~D"2022-11-03", ~D"2022-11-07"]
      assert todo.date_attrs == %{}
    end
  end

  describe "todos" do
    @invalid_attrs %{title: nil}

    #    test "list_todos/0 returns all todos" do
    #      todo = todo_fixture()
    #      assert General.list_all_todos() == [todo |> Todo.put_formatted_date]
    #    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert General.get_todo!(todo.id) == todo |> Todo.put_formatted_date()
    end

    test "create_todo/1 with valid data creates a todo" do
      valid_attrs = %{due_date: ~D[2022-01-01], title: "some title"}

      assert {:ok, %Todo{} = todo} = General.create_todo(valid_attrs)
      assert todo.due_date == ~D[2022-01-01]
      assert todo.title == "some title"
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = General.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      update_attrs = %{due_date: ~D[2022-01-02], title: "some updated title"}

      assert {:ok, %Todo{} = todo} = General.update_todo(todo, update_attrs)
      assert todo.due_date == ~D[2022-01-02]
      assert todo.title == "some updated title"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = General.update_todo(todo, @invalid_attrs)
      assert General.get_todo!(todo.id) == todo |> Todo.put_formatted_date()
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = General.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> General.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = General.change_todo(todo)
    end
  end

  describe "filter_todos_by_period/1" do
    test "(for week) contains todos contained in this week" do
      dynamic_todos_fixture()
      this_weeks_todos = General.list_todos() |> General.filter_todos_by_period(:this_week)
      assert this_weeks_todos |> Enum.any?(&(&1.title == "this week")) == true
    end

    test "(for week) contains todos beginning this week and ending next" do
      dynamic_todos_fixture()
      this_weeks_todos = General.list_todos() |> General.filter_todos_by_period(:this_week)
      assert this_weeks_todos |> Enum.any?(&(&1.title == "this week to next week")) == true
    end

    test "(for week) does not contain todos from _next week_" do
      dynamic_todos_fixture()
      this_weeks_todos = General.list_todos() |> General.filter_todos_by_period(:this_week)
      assert this_weeks_todos |> Enum.any?(&(&1.title == "next week")) == false
    end

    test "(for month) contains todos contained in this month" do
      dynamic_todos_fixture()
      this_months_todos = General.list_todos() |> General.filter_todos_by_period(:this_month)
      assert this_months_todos |> Enum.any?(&(&1.title == "this month")) == true
      assert this_months_todos |> Enum.count() >= 7
    end

    test "(for month) also contains todos beginning this month and ending next" do
      dynamic_todos_fixture()
      this_months_todos = General.list_todos() |> General.filter_todos_by_period(:this_month)
      assert this_months_todos |> Enum.any?(&(&1.title == "this month to next month")) == true
    end

    test "(for month) does not contain todos from _next month_" do
      dynamic_todos_fixture()
      this_months_todos = General.list_todos() |> General.filter_todos_by_period(:this_month)
      assert this_months_todos |> Enum.any?(&(&1.title == "next month")) == false
    end

    test "(for today) contains today's todos" do
      dynamic_todos_fixture()
      todays_todos = General.list_todos() |> General.filter_todos_by_period(:today)
      assert todays_todos |> Enum.any?(&(&1.title == "today")) == true
      assert todays_todos |> Enum.any?(&(&1.title == "until today")) == true
    end

    test "(for :undefined) contains todos with no date" do
      dynamic_todos_fixture()
      undefined_todos = General.list_todos() |> General.filter_todos_by_period(:undefined)
      assert undefined_todos |> Enum.count() == 1
      assert undefined_todos |> Enum.any?(&(&1.title == "some day")) == true
    end
  end

  describe "filter_pending_todos/1" do
    test "contains only todos due before today" do
      dynamic_todos_fixture()
      pending_todos = General.list_todos() |> General.filter_pending_todos()
      assert pending_todos |> Enum.any?(&(&1.title == "yesterday")) == true
      assert pending_todos |> Enum.any?(&(&1.title == "last week")) == true
      assert pending_todos |> Enum.count() >= 2
      # %{title: "early this year"}
      assert pending_todos |> Enum.count() <= 3
    end
  end

  describe "chores" do
    alias Dutu.General.Chore

    import Dutu.GeneralFixtures

    @invalid_attrs %{last_done_at: nil, rrule: nil, title: nil}

    test "list_chores/0 returns all chores" do
      chore = chore_fixture()
      assert General.list_chores() == [chore]
    end

    test "get_chore!/1 returns the chore with given id" do
      chore = chore_fixture()
      assert General.get_chore!(chore.id) == chore
    end

    test "create_chore/1 with valid data creates a chore" do
      valid_attrs = %{last_done_at: ~N[2022-01-07 09:58:00], rrule: %{}, title: "some title"}

      assert {:ok, %Chore{} = chore} = General.create_chore(valid_attrs)
      assert chore.last_done_at == ~N[2022-01-07 09:58:00]
      assert chore.rrule == %{}
      assert chore.title == "some title"
    end

    test "create_chore/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = General.create_chore(@invalid_attrs)
    end

    test "update_chore/2 with valid data updates the chore" do
      chore = chore_fixture()

      update_attrs = %{
        last_done_at: ~N[2022-01-08 09:58:00],
        rrule: %{},
        title: "some updated title"
      }

      assert {:ok, %Chore{} = chore} = General.update_chore(chore, update_attrs)
      assert chore.last_done_at == ~N[2022-01-08 09:58:00]
      assert chore.rrule == %{}
      assert chore.title == "some updated title"
    end

    test "update_chore/2 with invalid data returns error changeset" do
      chore = chore_fixture()
      assert {:error, %Ecto.Changeset{}} = General.update_chore(chore, @invalid_attrs)
      assert chore == General.get_chore!(chore.id)
    end

    test "delete_chore/1 deletes the chore" do
      chore = chore_fixture()
      assert {:ok, %Chore{}} = General.delete_chore(chore)
      assert_raise Ecto.NoResultsError, fn -> General.get_chore!(chore.id) end
    end

    test "change_chore/1 returns a chore changeset" do
      chore = chore_fixture()
      assert %Ecto.Changeset{} = General.change_chore(chore)
    end
  end
end
