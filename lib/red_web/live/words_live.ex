defmodule RedWeb.WordsLive do
  use RedWeb, :live_view
  alias Red.Practice.Card.Loader

  def mount(_params, _session, socket) do
    {:ok, perform_assigns(socket)}
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
      word_list_files: word_list_files
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

    <div class="mt-3">
      <%= for word_list_file <- @word_list_files do %>
        <div class="h-14 mx-auto flex flex-nowrap justify-between max-w-md odd:bg-gray-200 last:rounded-b-xl first:rounded-t-xl">
          <div class="pl-4 my-auto text-left">
            <%= display_file_name(word_list_file.file_name) %>
          </div>
          <div class="my-auto pr-4">
            <%= if word_list_file.already_loaded? do %>
              Already Loaded
            <% else %>
              <.button
                phx-click="load-file"
                phx-value-file_name={word_list_file.file_name}
                disabled={word_list_file.already_loaded?}
              >
                Load
              </.button>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
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
