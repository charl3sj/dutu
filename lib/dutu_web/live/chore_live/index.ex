defmodule DutuWeb.ChoreLive.Index do
	use DutuWeb, :live_view

	alias Dutu.General
	use Dutu.DateHelpers

	@impl true
	def mount(_params, _session, socket) do
		{:ok, assign(socket, :chores, list_chores())}
	end

	@impl true
	def handle_params(params, _url, socket) do
		{:noreply, apply_action(socket, socket.assigns.live_action, params)}
	end

	defp apply_action(socket, :index, _params) do
		socket
		|> assign(:page_title, "Chores")
		|> assign(:chore, nil)
	end

	defp apply_action(socket, :new, _params) do
		socket
		|> assign(:page_title, "New Chore")
		|> assign(:chore, %General.Chore{})
		|> assign(:chore_form, %General.ChoreForm{})
	end

	defp apply_action(socket, :edit, %{"id" => id}) do
		chore = General.get_chore!(id)
		socket
		|> assign(:page_title, "Edit Chore")
		|> assign(:chore, chore)
		|> assign(:chore_form, chore |> General.ChoreForm.from_chore)
	end

	@impl true
	def handle_event("delete", %{"id" => id}, socket) do
		chore = General.get_chore!(id)
		{:ok, _} = General.delete_chore(chore)

		{:noreply, assign(socket, :chores, list_chores())}
	end

	defp list_chores do
		General.list_chores() |> segment_chores()
	end

	defp segment_chores(chores) do
		%{
			every_x_days: General.filter_chores_by_frequency(chores, :daily),
			every_week: General.filter_chores_by_frequency(chores, :weekly)
		}
	end


end
