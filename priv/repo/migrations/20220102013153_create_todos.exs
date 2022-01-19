defmodule Dutu.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string, null: false
      add :due_date, :date
      add :approx_due_date, :daterange
      add :date_attrs, :map
      add :is_done, :boolean, default: false
      add :done_at, :naive_datetime
    end

    create constraint("todos", :due_date_and_approx_due_date_dont_occur_together,
             check:
               "(due_date IS NULL) != (approx_due_date IS NULL) OR ((due_date IS NULL) AND (approx_due_date IS NULL))"
           )

    create constraint("todos", :approx_due_date_must_have_date_attrs,
             check:
               "((approx_due_date IS NOT NULL) = (date_attrs IS NOT NULL)) OR (due_date IS NOT NULL)"
           )
  end
end
