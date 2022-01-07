defmodule DutuWeb.TodoLive.NewTodoForm do
	use DutuWeb, :live_component

	alias Dutu.General
	alias Dutu.General.TodoForm

	@impl true
	def update(%{todo_form: form} = assigns, socket) do
		form_changeset = General.change_todo_form(form)
		{:ok,
			socket
			|> assign(assigns)
			|> assign(:changeset, form_changeset)}
	end

	@impl true
	def handle_event("validate", %{"todo_form" => form_params}, socket) do
		form_changeset =
				socket.assigns.todo_form
				|> General.change_todo_form(form_params)
				|> Map.put(:action, :validate)
		{:noreply, assign(socket, :changeset, form_changeset)}
	end

	@impl true
	def handle_event("save", %{"todo_form" => form_params}, socket) do
		form_changeset = socket.assigns.todo_form
		                 |> General.change_todo_form(form_params)
		                 |> Map.put(:action, :insert)
		if !form_changeset.valid? do
			{:noreply, assign(socket, :changeset, form_changeset)}
		else
			todo_form = Ecto.Changeset.apply_changes(form_changeset)
			todo_params = TodoForm.to_todo_params(todo_form)
			save_todo(socket, socket.assigns.action, todo_params)
		end
	end

	defp save_todo(socket, :new, todo_params) do
		case General.create_todo(todo_params) do
			{:ok, _todo} ->
				{:noreply,
					socket
					|> put_flash(:info, "Todo created successfully")
					|> push_redirect(to: socket.assigns.return_to)}

			{:error, %Ecto.Changeset{} = _changeset} ->
				{:noreply, socket
				           |> put_flash(:error, "An unexpected error occurred while creating todo")
				           |> push_redirect(to: socket.assigns.return_to)}
		end
	end

	defp save_todo(socket, :edit, todo_params) do
		case General.update_todo(socket.assigns.todo, todo_params) do
			{:ok, _todo} ->
				{:noreply,
					socket
					|> put_flash(:info, "Todo updated successfully")
					|> push_redirect(to: socket.assigns.return_to)}

			{:error, %Ecto.Changeset{} = _changeset} ->
				{:noreply, socket
				           |> put_flash(:error, "An unexpected error occurred while updating todo")
				           |> push_redirect(to: socket.assigns.return_to)}
		end
	end

end