defmodule RedWeb.PracticeLive do
  use RedWeb, :live_view
  alias Red.Words

  def mount(_params, _session, socket) do
    form =
      Red.Api.Attempt
      |> AshPhoenix.Form.for_create(:try,
        api: RedApi,
        forms: [auto?: true]
      )
      |> to_form()

    socket =
      assign(socket, %{
        form: form,
        word: Words.random_word()
      })

    Process.send_after(self(), :say, 1)

    {:ok, socket}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", %{"tried_spelling" => tried_spelling}, socket) do
    Red.Api.Attempt
    |> Ash.Changeset.for_create(:try, %{
      correct_spelling: "the",
      tried_spelling: tried_spelling,
      user_id: socket.assigns.current_user.id
    })
    |> Red.Api.create!()

    {:noreply, socket}
  end

  def handle_info(:say, socket) do
    {:noreply, push_event(socket, "Say", %{word: socket.assigns.word})}
  end
end
