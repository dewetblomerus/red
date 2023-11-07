defmodule RedWeb.PracticeLive.StatsComponent do
  use Phoenix.Component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-center">
      <div class="border-2 border-gray-500 rounded-xl">
        <%= render_row("Future Review", @user.count_cards_review) %>
        <%= render_row("Practicing", @user.count_cards_practice) %>
        <%= render_row("New Untried Cards", @user.count_cards_untried) %>
      </div>
    </div>
    """
  end

  def render_row(description, stat) do
    assigns = %{description: description, stat: stat}

    ~H"""
    <div class="h-8 flex items-center justify-between odd:bg-gray-200 last:rounded-b-xl first:rounded-t-xl px-2">
      <div><%= @description %></div>
      <div class="pl-3"><%= @stat %></div>
    </div>
    """
  end
end
