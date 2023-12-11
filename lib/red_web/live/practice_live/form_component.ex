defmodule RedWeb.PracticeLive.FormComponent do
  use RedWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Practice
      </.header>
      <audio id="phraseAudio" autoplay src={@audio_url} controls></audio>
      <.button id="repeatButton">Repeat Audio</.button>
      <div class="text-sm">Spacebar also repeats audio</div>
      <.simple_form
        autocapitalize="none"
        autocomplete="off"
        for={@form}
        id="try-form"
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
        spellcheck="false"
      >
        <div class="mx-auto max-w-xs">
          <.input
            autocomplete="one-time-code"
            autofocus
            field={@form[:tried_spelling]}
            label="Type the word below"
            role="presentation"
            spellcheck="false"
            type="text"
          />
        </div>
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
  def handle_event("validate", %{"card" => card_params}, socket) do
    {
      :noreply,
      assign(
        socket,
        form: AshPhoenix.Form.validate(socket.assigns.form, card_params)
      )
    }
  end

  def handle_event(
        "save",
        %{"card" => %{"tried_spelling" => raw_tried_spelling} = params},
        socket
      ) do
    tried_spelling =
      raw_tried_spelling
      |> String.trim()
      |> String.replace(" ", "")

    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, card} ->
        notify_parent(
          {:tried,
           %{
             correct_spelling: card.word,
             tried_spelling: tried_spelling
           }}
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
