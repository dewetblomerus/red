defmodule RedWeb.PracticeLive.FormComponent do
  use RedWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Spell the Word You Hear
        <:subtitle>Just try your best.</:subtitle>
      </.header>
      <.simple_form
        for={@form}
        id="attempt-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:tried_spelling]} type="text" label="Tried spelling" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Attempt</.button>
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
  def handle_event("validate", %{"attempt" => attempt_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, attempt_params))}
  end

  def handle_event("save", %{"attempt" => attempt_params}, socket) do
    hydrated_params =
      Map.merge(
        attempt_params,
        %{
          "user_id" => socket.assigns.current_user.id,
          "correct_spelling" => socket.assigns.correct_spelling
        },
        fn _k, _v1, _v2 ->
          raise("duplicate key")
        end
      )

    case AshPhoenix.Form.submit(socket.assigns.form, params: hydrated_params) do
      {:ok, attempt} ->
        notify_parent({:saved, attempt})

        socket =
          socket
          |> put_flash(:info, "Attempt #{socket.assigns.form.source.type}d successfully")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{attempt: attempt}} = socket) do
    form =
      if attempt do
        AshPhoenix.Form.for_update(attempt, :update,
          api: Red.Api,
          as: "attempt",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Red.Api.Attempt, :create,
          api: Red.Api,
          as: "attempt",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
