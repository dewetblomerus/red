defmodule RedWeb.AttemptLive.Show do
  use RedWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Attempt <%= @attempt.id %>
      <:subtitle>This is a attempt record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/attempts/#{@attempt}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit attempt</.button>
        </.link>
      </:actions>
    </.header>

    <.back navigate={~p"/attempts"}>Back to attempts</.back>

    <.modal
      :if={@live_action == :edit}
      id="attempt-modal"
      show
      on_cancel={JS.patch(~p"/attempts/#{@attempt}")}
    >
      <.live_component
        module={RedWeb.AttemptLive.FormComponent}
        id={@attempt.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        attempt={@attempt}
        patch={~p"/attempts/#{@attempt}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:attempt, Red.Api.get!(Red.Api.Attempt, id, actor: socket.assigns.current_user))}
  end

  defp page_title(:show), do: "Show Attempt"
  defp page_title(:edit), do: "Edit Attempt"
end
