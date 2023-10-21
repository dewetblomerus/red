defmodule RedWeb.PracticeLive.FormComponent do
  use RedWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Spell the Word You Hear
        <:subtitle>Press spacebar to hear it again.</:subtitle>
      </.header>
      <.simple_form
        for={@form}
        id="try-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:tried_spelling]} type="text" label="Tried spelling" autofocus />
        <:actions>
          <.button phx-disable-with="Saving...">Submit</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", params, socket) do
    {
      :noreply,
      assign(
        socket,
        form: AshPhoenix.Form.validate(socket.assigns.form, params)
      )
    }
  end

  def handle_event("save", %{"card" => %{"tried_spelling" => tried_spelling} = params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, card} ->
        notify_parent(
          {:tried, %{correct_spelling: card.word, tried_spelling: String.trim(tried_spelling)}}
        )

        {:noreply, assign_form(socket)}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(socket) do
    form =
      AshPhoenix.Form.for_update(socket.assigns.card, :try,
        api: Red.Practice,
        as: "card",
        actor: socket.assigns.current_user
      )
      |> to_form()

    assign(socket, form: form)
  end
end
