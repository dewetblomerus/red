defmodule RedWeb.PracticeLive do
  use RedWeb, :live_view
  alias Red.Words

  def mount(_params, _session, socket) do
    socket =
      assign(socket, %{
        word: Words.random_word()
      })

    Process.send_after(self(), :say, 200)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="hooker" phx-hook="Say"></div>
    <div class="container">
      <div class="row">
        <div class="col-12">
          <h1>Type the word you hear</h1>
          <%= @word %>
        </div>
      </div>
    </div>
    """
  end

  def handle_info(:say, socket) do
    # Process.send_after(self(), :say, 2000)
    {:noreply, push_event(socket, "Say", %{word: socket.assigns.word, what: "hello"})}
  end
end
