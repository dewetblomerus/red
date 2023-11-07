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
      <h1 class="text-2xl">
        Stats
      </h1>

      <div class="p-1 mx-auto bg-slate-200 rounded max-w-xs">
        <table>
          <tr>
            <td class="text-left">Future Review</td>
            <td><%= @user.count_cards_review %></td>
          </tr>
          <tr>
            <td class="text-left">Practicing</td>
            <td><%= @user.count_cards_practice %></td>
          </tr>
          <tr>
            <td class="text-left">New Cards</td>
            <td><%= @user.count_cards_untried %></td>
          </tr>
        </table>
      </div>
    </div>
    """
  end
end
