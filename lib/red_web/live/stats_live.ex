defmodule RedWeb.StatsLive do
  use RedWeb, :live_view
  alias Red.Practice.Card.Loader

  def mount(_params, _session, socket) do
    {:ok, socket}
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
            <td>9</td>
          </tr>
          <tr>
            <td class="text-left">Practicing</td>
            <td>4</td>
          </tr>
          <tr>
            <td class="text-left">New Cards</td>
            <td>30</td>
          </tr>
        </table>
      </div>
    </div>
    """
  end
end
