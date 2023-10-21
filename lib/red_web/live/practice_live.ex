defmodule RedWeb.PracticeLive do
  use RedWeb, :live_view
  alias RedWeb.PracticeLive.FormComponent
  alias Red.Practice.Card

  def mount(_params, _session, socket) do
    card = get_next_card(socket)

    socket =
      assign(socket, %{
        attempt: nil,
        card: card,
        page_title: "Practice"
      })

    Process.send_after(self(), :say, 1)

    {:ok, socket}
  end

  def get_next_card(socket) do
    card =
      case Card.next(actor: socket.assigns.current_user) do
        {:ok, card} ->
          card

        {:error, %Ash.Error.Query.NotFound{}} ->
          nil
      end
  end

  def handle_info(:say, socket) do
    if socket.assigns.card do
      {:noreply, push_event(socket, "Say", %{word: socket.assigns.card.word})}
    else
      {:noreply, socket}
    end
  end

  def handle_info(
        {FormComponent,
         {:tried, %{tried_spelling: tried_spelling, correct_spelling: correct_spelling}}},
        socket
      ) do
    case tried_spelling == correct_spelling do
      true ->
        socket =
          socket
          |> assign(:card, get_next_card(socket))
          |> clear_flash()
          |> put_flash(:info, "Correct!")

        Process.send_after(self(), :say, 1)
        {:noreply, socket}

      false ->
        socket =
          socket
          |> clear_flash()
          |> assign(:card, Red.Practice.reload!(socket.assigns.card))
          |> put_flash(
            :error,
            "The word was '#{correct_spelling}' but you typed '#{tried_spelling}'."
          )

        Process.send_after(self(), :say, 1)
        {:noreply, socket}
    end
  end
end
