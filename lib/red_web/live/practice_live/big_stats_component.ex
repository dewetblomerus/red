defmodule RedWeb.PracticeLive.BigStatsComponent do
  use Phoenix.Component
  require Ash.Query

  def render(assigns) do
    ~H"""
    <div class="flex-col justify-center">
      <div class="border-2 border-gray-500 rounded-xl">
        <div class="px-2 text-xl rounded-t-xl">Practicing Words</div>

        <div class="h-8 flex items-center justify-between px-2 font-semibold">
          <div class="mr-4">Word</div>
          <div>Phrase</div>
        </div>
        <%= for card <- practicing_cards(@user) do %>
          <%= render_practicing_card(card) %>
        <% end %>
      </div>

      <div class="mt-4 border-2 border-gray-500 rounded-xl">
        <div class="px-2 text-xl rounded-t-xl">Known Words</div>

        <div class="h-8 flex items-center justify-between px-2 font-semibold">
          <div class="mr-4">Word</div>
          <div>Review In</div>
        </div>
        <%= for card <- known_cards(@user) do %>
          <%= render_known_card(card) %>
        <% end %>
      </div>
    </div>
    """
  end

  def render_practicing_card(card) do
    assigns = %{card: card}

    ~H"""
    <div class="h-8 flex items-center justify-between odd:bg-gray-200 last:rounded-b-xl first:rounded-t-xl px-2">
      <div class="mr-4"><%= @card.word %></div>
      <div><%= @card.phrase %></div>
    </div>
    """
  end

  def render_known_card(card) do
    now_unix = "Etc/UTC" |> DateTime.now!() |> DateTime.to_unix()
    retry_at_unix = card.retry_at |> DateTime.to_unix()

    seconds = retry_at_unix - now_unix

    assigns = %{
      card: card,
      days_display: Red.IntervalDisplay.seconds_to_daystime(seconds)
    }

    ~H"""
    <div class="h-8 flex items-center justify-between odd:bg-gray-200 last:rounded-b-xl first:rounded-t-xl px-2">
      <div class="mr-4"><%= @card.word %></div>
      <div><%= @days_display %></div>
    </div>
    """
  end

  def practicing_cards(user) do
    require Ash.Query

    day_of_seconds = round(:timer.hours(24) / 1000)

    Red.Practice.Card
    |> Ash.Query.filter(user_id == ^user.id)
    |> Ash.Query.filter(interval_in_seconds < ^day_of_seconds)
    |> Ash.Query.sort([:word])
    |> Ash.Query.load(:interval_in_seconds)
    |> Ash.read!()
  end

  def known_cards(user) do
    require Ash.Query

    day_of_seconds = round(:timer.hours(24) / 1000)

    Red.Practice.Card
    |> Ash.Query.filter(user_id == ^user.id)
    |> Ash.Query.filter(interval_in_seconds >= ^day_of_seconds)
    |> Ash.Query.sort(:retry_at)
    |> Ash.read!()
  end
end
