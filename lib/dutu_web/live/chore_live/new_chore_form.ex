defmodule DutuWeb.ChoreLive.NewChoreForm do
  use DutuWeb, :live_component

  alias Dutu.General
  alias Dutu.General.ChoreForm

  @impl true
  def update(%{chore_form: form} = assigns, socket) do
    form_changeset = General.change_chore_form(form)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, form_changeset)}
  end

  @impl true
  def handle_event("validate", %{"chore_form" => form_params}, socket) do
    form_changeset =
      socket.assigns.chore_form
      |> General.change_chore_form(form_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, form_changeset)}
  end

  @impl true
  def handle_event("save", %{"chore_form" => form_params}, socket) do
    form_changeset =
      socket.assigns.chore_form
      |> General.change_chore_form(form_params)
      |> Map.put(:action, :insert)

    if !form_changeset.valid? do
      {:noreply, assign(socket, :changeset, form_changeset)}
    else
      chore_form = Ecto.Changeset.apply_changes(form_changeset)
      chore_params = ChoreForm.to_chore_params(chore_form)
      save_chore(socket, socket.assigns.action, chore_params)
    end
  end

  defp save_chore(socket, :new, chore_params) do
    case General.create_chore(chore_params) do
      {:ok, _chore} ->
        {:noreply,
         socket
         |> put_flash(:info, "Chore created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "An unexpected error occurred while creating chore")
         |> push_redirect(to: socket.assigns.return_to)}
    end
  end

  defp save_chore(socket, :edit, chore_params) do
    case General.update_chore(socket.assigns.chore, chore_params) do
      {:ok, _chore} ->
        {:noreply,
         socket
         |> put_flash(:info, "Chore updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "An unexpected error occurred while updating chore")
         |> push_redirect(to: socket.assigns.return_to)}
    end
  end
end
