defmodule Dutu.GeneralFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dutu.General` context.
  """
  import Timex,
    only: [shift: 2, end_of_week: 1, end_of_month: 1, end_of_quarter: 1, end_of_year: 1]

  import Dutu.DateHelpers
  use Dutu.DateHelpers

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{title: "some title"})
      |> Dutu.General.create_todo()

    todo
  end

  def dynamic_todos_fixture() do
    end_of_this_year =
      start_of_this_year()
      |> end_of_year

    [
      %{title: "today", due_date: today()},
      %{
        title: "until today",
        approx_due_date: [nil, today()],
        date_attrs: %{
          "type" => @due_date_types.before
        }
      },
      %{title: "tomorrow", due_date: tomorrow()},
      %{
        title: "until tomorrow",
        approx_due_date: [nil, tomorrow()],
        date_attrs: %{
          "type" => @due_date_types.before
        }
      },
      %{title: "yesterday", due_date: shift(today(), days: -1)},
      %{title: "some day"},
      %{
        title: "last week",
        approx_due_date: [shift(today(), days: -12), shift(today(), days: -8)],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "this year",
        approx_due_date: [shift(end_of_this_year, days: -5), end_of_this_year],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "early this year",
        approx_due_date: [
          shift(start_of_this_year(), weeks: 1),
          shift(start_of_this_year(), weeks: 2)
        ],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "next year",
        approx_due_date: [start_of_next_year(), shift(start_of_next_year(), days: 5)],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "this week",
        approx_due_date: [
          shift(start_of_this_week(), days: 2),
          start_of_this_week()
          |> end_of_week
        ],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "next week",
        approx_due_date: [
          shift(start_of_next_week(), days: 2),
          start_of_next_week()
          |> end_of_week
        ],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "this week to next week",
        approx_due_date: [
          shift(start_of_this_week(), days: 3),
          shift(start_of_next_week(), days: 3)
        ],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "this month",
        approx_due_date: [
          shift(start_of_this_month(), days: 3),
          start_of_this_month()
          |> end_of_month
        ],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "next month",
        approx_due_date: [
          shift(start_of_next_month(), days: 3),
          start_of_next_month()
          |> end_of_month
        ],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "this month to next month",
        approx_due_date: [
          shift(start_of_this_month(), weeks: 1),
          shift(start_of_next_month(), weeks: 2)
        ],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "this quarter",
        approx_due_date: [
          shift(start_of_this_quarter(), days: 3),
          start_of_this_quarter()
          |> end_of_quarter
        ],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "next quarter",
        approx_due_date: [
          shift(start_of_next_quarter(), days: 3),
          start_of_next_quarter()
          |> end_of_quarter
        ],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      },
      %{
        title: "this quarter to next quarter",
        approx_due_date: [
          shift(start_of_this_quarter(), weeks: 1),
          shift(start_of_next_quarter(), weeks: 2)
        ],
        date_attrs: %{
          "type" => @due_date_types.between
        }
      }
    ]
    |> Enum.map(fn todo -> todo_fixture(todo) end)
  end

  @doc """
  Generate a chore.
  """
  def chore_fixture(attrs \\ %{}) do
    {:ok, chore} =
      attrs
      |> Enum.into(%{
        last_done_at: ~N[2022-01-07 09:58:00],
        rrule: %{},
        title: "some title"
      })
      |> Dutu.General.create_chore()

    chore
  end
end
