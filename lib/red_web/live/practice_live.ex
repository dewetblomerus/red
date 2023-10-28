defmodule RedWeb.PracticeLive do
  use RedWeb, :live_view
  alias RedWeb.PracticeLive.FormComponent
  alias Red.Practice.Card

  def mount(_params, _session, old_socket) do
    socket =
      old_socket
      |> assign_card()
      |> assign(%{
        page_title: "Practice"
      })

    Process.send_after(self(), :say, 100)

    {:ok, socket}
  end

  def assign_card(socket) do
    assign(socket, card: get_next_card(socket.assigns.current_user))
  end

  def get_next_card(user) do
    case Card.next(actor: user) do
      {:ok, card} ->
        card

      {:error, %Ash.Error.Query.NotFound{}} ->
        Red.Practice.Card.Loader.call(user)
    end
  end

  def handle_info(:say, socket) do
    if socket.assigns.card do
      {:noreply,
       push_event(socket, "Say", %{
         utterance:
           "#{socket.assigns.card.word}, as in #{socket.assigns.card.phrase}"
       })}
    else
      {:noreply, socket}
    end
  end

  def handle_info(
        {FormComponent,
         {:tried,
          %{tried_spelling: tried_spelling, correct_spelling: correct_spelling}}},
        socket
      ) do
    case tried_spelling == correct_spelling do
      true ->
        socket =
          socket
          |> assign_card()
          |> clear_flash()
          |> put_flash(:info, "Correct! #{success_emoji()}")

        Process.send_after(self(), :say, 100)
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

  defp success_emoji() do
    ~w(✅ 🎉 ✨ 😍 🥳 💪 🔥) |> Enum.random()
  end
end
