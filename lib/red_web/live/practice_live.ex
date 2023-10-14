defmodule RedWeb.PracticeLive do
  use RedWeb, :live_view
  alias Red.Words
  alias RedWeb.PracticeLive.FormComponent
  alias Red.Api.Attempt

  def mount(_params, _session, socket) do
    socket =
      assign(socket, %{
        attempt: nil,
        page_title: "Practice",
        word: Words.random_word()
      })

    Process.send_after(self(), :say, 1)

    {:ok, socket}
  end

  def handle_info(:say, socket) do
    {:noreply, push_event(socket, "Say", %{word: socket.assigns.word})}
  end

  def handle_info(
        {FormComponent,
         {:saved,
          %Attempt{
            tried_spelling: tried_spelling,
            correct_spelling: correct_spelling
          }}},
        socket
      ) do
    case tried_spelling == correct_spelling do
      true ->
        socket =
          socket
          |> assign(:word, Words.random_word())
          |> put_flash(:info, "'#{tried_spelling}' is correct!.")

        Process.send_after(self(), :say, 1)
        {:noreply, socket}

      false ->
        socket =
          socket
          |> put_flash(
            :error,
            "The word was '#{correct_spelling}' but you typed '#{tried_spelling}'."
          )

        Process.send_after(self(), :say, 1)
        {:noreply, socket}
    end
  end
end
