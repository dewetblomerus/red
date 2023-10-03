defmodule RedWeb.PracticeLive do
  use RedWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="container">
      <div class="row">
        <div class="col-12">
          <h1>Practice</h1>
        </div>
      </div>
    </div>
    """
  end
end
