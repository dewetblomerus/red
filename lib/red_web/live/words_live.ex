defmodule RedWeb.WordsLive do
  use RedWeb, :live_view

  alias Red.Practice.Card.Loader
  alias Red.Words

  def mount(_params, _session, old_socket) do
    socket =
      old_socket
      |> assign(page_title: "Words")
      |> perform_assigns()

    {:ok, socket}
  end

  def perform_assigns(socket) do
    word_list_files = Loader.list!(socket.assigns.current_user)

    any_loaded? =
      word_list_files
      |> Enum.any?(fn file_map ->
        file_map.already_loaded?
      end)

    assign(socket,
      any_loaded?: any_loaded?,
      word_list_files: Words.sort_word_lists(word_list_files)
    )
  end

  def render(assigns) do
    ~H"""
    <h1 class="text-2xl">
      Load word lists in the order that you need to learn them.
    </h1>

    <%= if @any_loaded? do %>
      <div class="pt-2">
        <a href="/">
          <.button>Start Practicing</.button>
        </a>
      </div>
    <% end %>

    <.live_component
      id="words-component"
      module={RedWeb.PracticeLive.WordsComponent}
      word_list_files={@word_list_files}
    />
    """
  end

  def handle_event(
        "load-file",
        %{"file_name" => file_name},
        socket
      ) do
    Loader.load(socket.assigns.current_user, file_name)

    {:noreply, perform_assigns(socket)}
  end

  def display_file_name(file_name) do
    file_name
    |> String.trim_trailing(".csv")
    |> String.replace("-", " ")
    |> String.capitalize()
  end
end
