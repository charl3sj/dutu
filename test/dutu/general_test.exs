defmodule Dutu.GeneralTest do
  use Dutu.DataCase

  alias Dutu.General
  alias Dutu.General.Todo

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
      assert {:error, %Ecto.Changeset{} = changeset} = General.create_todo(%{due_date: ~D"2022-11-03"})
      assert changeset.errors == [title: {"can't be blank", [validation: :required]}]
    end

    test "with both `due_date` and `approx_due_date` fails constraint check" do
      valid_attrs = %{title: "some title", due_date: ~D"2022-11-03", approx_due_date: [~D"2022-11-03", ~D"2022-11-07"], date_attrs: %{}}
      assert {:error, %Ecto.Changeset{} = changeset} = General.create_todo(valid_attrs)
      assert changeset.errors == [
               approx_due_date: {"is invalid", [constraint: :check,
                 constraint_name: "due_date_and_approx_due_date_dont_occur_together"]}]
    end

    test "with `title` and `approx_due_date` without `date_attrs` fails constraint check" do
      invalid_attrs = %{title: "some title", approx_due_date: [~D"2022-11-03", ~D"2022-11-07"]}
      assert {:error, %Ecto.Changeset{} = changeset} = General.create_todo(invalid_attrs)
      assert changeset.errors == [
               date_attrs: {"is invalid", [constraint: :check,
                 constraint_name: "approx_due_date_must_have_date_attrs"]}]
    end

    test "with `title` and `approx_due_date` with `date_attrs` creates a todo" do
      valid_attrs = %{title: "some title", approx_due_date: [~D"2022-11-03", ~D"2022-11-07"], date_attrs: %{}}
      assert {:ok, %Todo{} = todo} = General.create_todo(valid_attrs)
      assert todo.title == "some title"
      assert todo.approx_due_date == [~D"2022-11-03", ~D"2022-11-07"]
      assert todo.date_attrs == %{}
    end
  end

  describe "todos" do

    import Dutu.GeneralFixtures

    @invalid_attrs %{title: nil}

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert General.list_all_todos() == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert General.get_todo!(todo.id) == todo
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
      assert todo == General.get_todo!(todo.id)
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
end
