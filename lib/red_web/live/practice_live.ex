defmodule RedWeb.PracticeLive do
  use RedWeb, :live_view

  alias Red.Practice.Card
  alias Red.Practice.Card.{Loader, Try}
  alias Red.Words
  alias RedWeb.PracticeLive.FormComponent

  def mount(
        _params,
        _session,
        %Phoenix.LiveView.Socket{assigns: %{current_user: %Red.Accounts.User{}}} =
          old_socket
      ) do
    socket =
      old_socket
      |> assign_card()
      |> assign_progress()
      |> assign(%{
        page_title: "Practice"
      })
      |> redirect_to_load_words_if_needed()

    Process.send_after(self(), :say, 100)

    {:ok, socket}
  end

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def redirect_to_load_words_if_needed(socket) do
    if socket.assigns.card do
      socket
    else
      reviewed_today_count =
        Ash.load!(
          socket.assigns.current_user,
          [:count_cards_reviewed_today]
        ).count_cards_reviewed_today

      if reviewed_today_count < socket.assigns.current_user.daily_goal &&
           !Loader.all_loaded?(socket.assigns.current_user) do
        redirect(socket, to: "/words")
      else
        socket
      end
    end
  end

  def assign_card(socket) do
    card = get_next_card(socket.assigns.current_user)

    word_list_files =
      if card do
        nil
      else
        Loader.list!(socket.assigns.current_user)
        |> Enum.filter(fn file_map ->
          file_map.already_loaded?
        end)
      end

    assign(
      socket,
      card: card,
      word_list_files: Words.sort_word_lists(word_list_files)
    )
  end

  def assign_progress(socket) do
    user =
      Ash.load!(socket.assigns.current_user, [
        :count_cards_goal_today,
        :count_cards_practice,
        :count_cards_review,
        :count_cards_reviewed_today,
        :count_cards_succeeded_today,
        :count_cards_untried
      ])

    assign(
      socket,
      count_cards_succeeded_today: user.count_cards_succeeded_today,
      count_cards_goal_today: max(user.count_cards_goal_today, user.daily_goal),
      current_user: user
    )
  end

  def get_next_card(user) do
    case Card.next(actor: user) do
      {:ok, card} ->
        card

      {:error, %Ash.Error.Invalid{errors: [%Ash.Error.Query.NotFound{}]}} ->
        nil
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
    case Try.check_is_correct?(
           correct_spelling,
           tried_spelling
         ) do
      true ->
        socket =
          socket
          |> assign_card()
          |> assign_progress()
          |> clear_flash()
          |> put_flash(:info, correct_message())
          |> redirect_to_load_words_if_needed()

        Process.send_after(self(), :say, 100)
        {:noreply, socket}

      false ->
        socket =
          socket
          |> assign_progress()
          |> clear_flash()
          |> assign(:card, Ash.reload!(socket.assigns.card))
          |> put_flash(
            :error,
            "The word was '#{correct_spelling}' but you typed '#{tried_spelling}'."
          )

        Process.send_after(self(), :say, 1)
        {:noreply, socket}
    end
  end

  defp correct_message do
    phrase =
      [
        "Correct!",
        "Good job!",
        "Nice!",
        "Well done!",
        "You got it!",
        "That's it!",
        "Nailed it!"
      ]
      |> Enum.random()

    emoji = Enum.random(success_emoji())

    "#{phrase} #{emoji}"
  end

  defp success_emoji do
    ~w(
      ✅
      ✨
      ⭐️
      🌟
      🎀
      🎁
      🎈
      🎉
      🎊
      🎖️
      🏆
      💥
      💪
      💯
      🔥
      🤗
      🤘
      🤙
      🤟
      🤩
      🥇
      🥳
      😍
    )
  end

  def success_streak(number, goal) do
    emojis =
      success_emoji()
      |> Stream.cycle()
      |> Enum.take(number)

    blanks_count = (goal - number) |> max(0)

    blanks = ["_"] |> Stream.cycle() |> Enum.take(blanks_count)

    emojis ++ blanks
  end
end
