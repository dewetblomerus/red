defmodule RedWeb.PracticeLive do
  use RedWeb, :live_view
  alias RedWeb.PracticeLive.FormComponent
  alias Red.Practice.Card

  def mount(_params, _session, socket) do
    due_today_count = get_due_today_count(socket.assigns.current_user)

    card = get_next_card(socket, due_today_count)

    socket =
      assign(socket, %{
        attempt: nil,
        card: card,
        due_today_count: due_today_count,
        page_title: "Practice"
      })

    Process.send_after(self(), :say, 100)

    {:ok, socket}
  end

  defp get_due_today_count(user) do
    Red.Practice.Card
    |> Ash.Query.for_read(
      :due_in,
      %{
        time_amount: 8,
        time_unit: :hour,
        max_correct_streak: 5
      },
      actor: user
    )
    |> Red.Practice.read!()
    |> Enum.count()
  end

  def get_next_card(socket, due_today_count) when due_today_count >= 20 do
    nil
  end

  def get_next_card(socket, _due_today_count) do
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
      {:noreply,
       push_event(socket, "Say", %{
         utterance: "#{socket.assigns.card.word}, as in #{socket.assigns.card.phrase}"
       })}
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
        due_today_count = get_due_today_count(socket.assigns.current_user)

        socket =
          socket
          |> assign(%{
            card: get_next_card(socket, due_today_count),
            due_today_count: due_today_count
          })
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
