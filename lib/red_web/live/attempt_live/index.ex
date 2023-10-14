defmodule RedWeb.AttemptLive.Index do
  use RedWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Attempts
      <:actions>
        <.link patch={~p"/attempts/new"}>
          <.button>New Attempt</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="attempts"
      rows={@streams.attempts}
      row_click={fn {_id, attempt} -> JS.navigate(~p"/attempts/#{attempt}") end}
    >
      <:col :let={{_id, attempt}} label="Id"><%= attempt.id %></:col>

      <:col :let={{_id, attempt}} label="Tried spelling"><%= attempt.tried_spelling %></:col>

      <:col :let={{_id, attempt}} label="Correct spelling"><%= attempt.correct_spelling %></:col>

      <:col :let={{_id, attempt}} label="User"><%= attempt.user_id %></:col>

      <:action :let={{_id, attempt}}>
        <div class="sr-only">
          <.link navigate={~p"/attempts/#{attempt}"}>Show</.link>
        </div>

        <.link patch={~p"/attempts/#{attempt}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, attempt}}>
        <.link
          phx-click={JS.push("delete", value: %{id: attempt.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="attempt-modal"
      show
      on_cancel={JS.patch(~p"/attempts")}
    >
      <.live_component
        module={RedWeb.AttemptLive.FormComponent}
        id={(@attempt && @attempt.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        attempt={@attempt}
        patch={~p"/attempts"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:attempts, Red.Api.read!(Red.Api.Attempt, actor: socket.assigns[:current_user]))
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Attempt")
    |> assign(:attempt, Red.Api.get!(Red.Api.Attempt, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Attempt")
    |> assign(:attempt, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Attempts")
    |> assign(:attempt, nil)
  end

  @impl true
  def handle_info({RedWeb.AttemptLive.FormComponent, {:saved, attempt}}, socket) do
    {:noreply, stream_insert(socket, :attempts, attempt)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    attempt = Red.Api.get!(Red.Api.Attempt, id, actor: socket.assigns.current_user)
    Red.Api.destroy!(attempt, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :attempts, attempt)}
  end
end
