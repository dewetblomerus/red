defmodule RedWeb.StatsLive do
  use RedWeb, :live_view
  alias Red.Practice.Card.Loader

  def mount(_params, _session, socket) do
    user =
      Red.Accounts.load!(socket.assigns.current_user, [
        :count_cards_goal_today,
        :count_cards_practice,
        :count_cards_review,
        :count_cards_reviewed_today,
        :count_cards_succeeded_today,
        :count_cards_untried
      ])

    {:ok, assign(socket, user: user)}
  end

  def render(assigns) do
    ~H"""
    <div class="items-center">
      <a href="/">
        <.button>Start Practicing</.button>
      </a>
      <h1 class="text-2xl">
        Your Stats
      </h1>

      <RedWeb.PracticeLive.StatsComponent.render user={@user} />
    </div>
    """
  end
end
