defmodule Dutu.General.TodoTest do
  @moduledoc """
  This module defines tests for the 'Dutu.General.Todo' domain object
  """

  use Dutu.DataCase, async: true

  alias Dutu.General
  alias Dutu.General.Todo
  use Dutu.DateHelpers

  describe "put_formatted_date/1 ::" do
    test "todo with no due date" do
      todo = %Todo{title: "some title"}
             |> Todo.put_formatted_date
      assert todo.formatted_date == "undefined"
    end

    test "todo with `due_date`" do
      todo = %Todo{title: "some title", due_date: ~D"2022-04-22"}
             |> Todo.put_formatted_date
      assert todo.formatted_date == "Apr 22"
    end

    test "todo with `approx_due_date`" do
      todo = %Todo{title: "some title",
                   approx_due_date: [~D"2022-03-11", ~D"2022-03-15"],
                   date_attrs: %{"type" => @due_date_types.between}}
             |> Todo.put_formatted_date
      assert todo.formatted_date == "between Mar 11 and Mar 15"
      todo = %Todo{title: "some title",
               approx_due_date: [nil, ~D"2022-03-15"],
               date_attrs: %{"type" => @due_date_types.before}}
             |> Todo.put_formatted_date
      assert todo.formatted_date == "before Mar 15"
      todo = %Todo{title: "some title",
               approx_due_date: [~D"2022-03-11", nil],
               date_attrs: %{"type" => @due_date_types.after}}
             |> Todo.put_formatted_date
      assert todo.formatted_date == "after Mar 11"
    end
  end

  describe "due_on_date?/2 ::" do
    test "is true when todo has `due_date` exactly on specified day" do
      {:ok, todo} = General.create_todo(%{title: "some title", due_date: ~D"2022-11-03"})
      assert Todo.due_on_date?(todo, ~D"2022-11-03") == true
    end

    test "is false when todo's `due_date` is not on specified day" do
      {:ok, todo} = General.create_todo(%{title: "some title", due_date: ~D"2022-11-03"})
      assert Todo.due_on_date?(todo, ~D"2022-11-04") == false
    end

    test "is true when specified day is in range of todo's `approx_due_date` (inclusive bounds)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-11-03", ~D"2022-11-05"], date_attrs: %{"type" => @due_date_types.between}})
      assert Todo.due_on_date?(todo, ~D"2022-11-03") == true
      assert Todo.due_on_date?(todo, ~D"2022-11-04") == true
      assert Todo.due_on_date?(todo, ~D"2022-11-05") == true
    end

    test "is false when specified day is not in range of todo's `approx_due_date`" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-11-03", ~D"2022-11-05"], date_attrs: %{"type" => @due_date_types.between}})
      assert Todo.due_on_date?(todo, ~D"2022-11-02") == false
      assert Todo.due_on_date?(todo, ~D"2022-11-07") == false
    end

    test "💥 todo is due on EVERY date occuring BEFORE (& on) upper-bound, when lower-bound is unset" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [nil, ~D"2022-11-15"], date_attrs: %{"type" => @due_date_types.before}})
      assert Todo.due_on_date?(todo, ~D"2022-11-15") == true
      assert Todo.due_on_date?(todo, ~D"2022-11-01") == true
      assert Todo.due_on_date?(todo, ~D"2022-02-01") == true
    end

    test "💥 todo is due on EVERY date occuring AFTER (& on) lower-bound, when upper-bound is unset" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-11-03", nil], date_attrs: %{"type" => @due_date_types.after}})
      assert Todo.due_on_date?(todo, ~D"2022-11-03") == true
      assert Todo.due_on_date?(todo, ~D"2022-11-12") == true
      assert Todo.due_on_date?(todo, ~D"2022-12-21") == true
    end
  end

  describe "due_between?/2 ::" do
    test "todo \"between 2nd March and 10th March\" is due between \"1st March and 12th March\" (fully contained in range)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.between}})
      assert Todo.due_between?(todo, ~D"2022-03-01", ~D"2022-03-12") == true
    end

    test "todo \"between 2nd March and 10th March\" is due between \"1st March and 5th March\" (lower-bound in range)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.between}})
      assert Todo.due_between?(todo, ~D"2022-03-01", ~D"2022-03-05") == true
    end

    test "todo \"between 2nd March and 10th March\" is due between \"8th March and 15th March\" (upper-bound in range)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.between}})
      assert Todo.due_between?(todo, ~D"2022-03-08", ~D"2022-03-15") == true
    end

    test "todo \"between 2nd March and 10th March\" is NOT due between \"11th March and 15th March\" (due before specified range)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.between}})
      assert Todo.due_between?(todo, ~D"2022-03-11", ~D"2022-03-15") == false
    end

    test "todo \"between 2nd March and 10th March\" is NOT due between \"25th Feb and 1st March\" (due after specified range)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.between}})
      assert Todo.due_between?(todo, ~D"2022-02-25", ~D"2022-03-01") == false
    end

    test "todo \"after 2nd March\" is due between \"1st March and 5th March\" (overlaps range)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", nil], date_attrs: %{"type" => @due_date_types.after}})
      assert Todo.due_between?(todo, ~D"2022-03-01", ~D"2022-03-05") == true
    end

    test "todo \"after 2nd March\" is NOT due between \"25th Feb and 1st March\" (due after range ends)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", nil], date_attrs: %{"type" => @due_date_types.after}})
      assert Todo.due_between?(todo, ~D"2022-02-25", ~D"2022-03-01") == false
    end

    test "💥 todo \"after 2nd March\" is due between \"8th March and 15th March\" (due range begins before range begins)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", nil], date_attrs: %{"type" => @due_date_types.after}})
      assert Todo.due_between?(todo, ~D"2022-03-08", ~D"2022-03-15") == true
    end

    test "todo \"before 10th March\" is due between \"6th March and 15th March\" (overlaps range)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [nil, ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.before}})
      assert Todo.due_between?(todo, ~D"2022-03-06", ~D"2022-03-15") == true
    end

    test "todo \"before 10th March\" is NOT due between \"16th March and 21st March\" (due before range begins)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [nil, ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.before}})
      assert Todo.due_between?(todo, ~D"2022-03-16", ~D"2022-03-21") == false
    end

    test "💥 todo \"before 10th March\" is due between \"14th Feb and 19th Feb\" (due after range ends)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [nil, ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.before}})
      assert Todo.due_between?(todo, ~D"2022-02-14", ~D"2022-02-19") == true
    end
  end

  describe "due_before?/2 ::" do
    test "todo \"between 2nd March and 10th March\" is due before \"12th March\"" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.between}})
      assert Todo.due_before?(todo, ~D"2022-03-12") == true
    end

    test "todo \"between 2nd March and 10th March\" is NOT due before \"5th March\"" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.between}})
      assert Todo.due_before?(todo, ~D"2022-03-05") == false
    end

    test "todo \"between 2nd March and 10th March\" is NOT due before \"1st March\"" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-02", ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.between}})
      assert Todo.due_before?(todo, ~D"2022-03-01") == false
    end

    test "todo \"before 10th March\" is due before \"12th March\"" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [nil, ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.before}})
      assert Todo.due_before?(todo, ~D"2022-03-12") == true
    end

    test "💥 todo \"before 10th March\" is NOT due before \"5th March\" (because there are 5 days left to get to it)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [nil, ~D"2022-03-10"], date_attrs: %{"type" => @due_date_types.before}})
      assert Todo.due_before?(todo, ~D"2022-03-05") == false
    end

    test "💥 todo \"after 10th March\" is NOT due BEFORE \"12th March\" (not due before any date because no upper bound)" do
      {:ok, todo} = General.create_todo(%{title: "some title",
        approx_due_date: [~D"2022-03-10", nil], date_attrs: %{"type" => @due_date_types.after}})
      assert Todo.due_before?(todo, ~D"2022-03-12") == false
      assert Todo.due_before?(todo, ~D"2022-03-05") == false
    end

  end
end