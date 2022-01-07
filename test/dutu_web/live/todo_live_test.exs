defmodule DutuWeb.TodoLiveTest do
  use DutuWeb.ConnCase

  import Phoenix.LiveViewTest
  import Dutu.GeneralFixtures

  @create_attrs %{due_date: %{day: 1, month: 1, year: 2022}, title: "some title"}
  @update_attrs %{due_date: %{day: 2, month: 1, year: 2022}, title: "some updated title"}
  @invalid_attrs %{due_date: %{day: 30, month: 2, year: 2022}, title: nil}

  defp create_todo(_) do
    todo = todo_fixture()
    %{todo: todo}
  end

  describe "Index" do
    setup [:create_todo]

    test "lists all todos", %{conn: conn, todo: todo} do
      {:ok, _index_live, html} = live(conn, Routes.todo_index_path(conn, :index))

      assert html =~ "Listing Todos"
      assert html =~ todo.title
    end

    test "saves new todo", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.todo_index_path(conn, :index))

      assert index_live |> element("a", "New Todo") |> render_click() =~
               "New Todo"

      assert_patch(index_live, Routes.todo_index_path(conn, :new))

      assert index_live
             |> form("#todo-form", todo: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#todo-form", todo: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.todo_index_path(conn, :index))

      assert html =~ "Todo created successfully"
      assert html =~ "some title"
    end

    test "updates todo in listing", %{conn: conn, todo: todo} do
      {:ok, index_live, _html} = live(conn, Routes.todo_index_path(conn, :index))

      assert index_live |> element("#todo-#{todo.id} a", "Edit") |> render_click() =~
               "Edit Todo"

      assert_patch(index_live, Routes.todo_index_path(conn, :edit, todo))

      assert index_live
             |> form("#todo-form", todo: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#todo-form", todo: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.todo_index_path(conn, :index))

      assert html =~ "Todo updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes todo in listing", %{conn: conn, todo: todo} do
      {:ok, index_live, _html} = live(conn, Routes.todo_index_path(conn, :index))

      assert index_live |> element("#todo-#{todo.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#todo-#{todo.id}")
    end
  end

  describe "Show" do
    setup [:create_todo]

    test "displays todo", %{conn: conn, todo: todo} do
      {:ok, _show_live, html} = live(conn, Routes.todo_show_path(conn, :show, todo))

      assert html =~ "Show Todo"
      assert html =~ todo.title
    end

    test "updates todo within modal", %{conn: conn, todo: todo} do
      {:ok, show_live, _html} = live(conn, Routes.todo_show_path(conn, :show, todo))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Todo"

      assert_patch(show_live, Routes.todo_show_path(conn, :edit, todo))

      assert show_live
             |> form("#todo-form", todo: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#todo-form", todo: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.todo_show_path(conn, :show, todo))

      assert html =~ "Todo updated successfully"
      assert html =~ "some updated title"
    end
  end
end
