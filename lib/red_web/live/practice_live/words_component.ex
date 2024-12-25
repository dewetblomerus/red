defmodule RedWeb.PracticeLive.WordsComponent do
  use RedWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-3 border-2 border-gray-500 rounded-xl">
      <%= for word_list_file <- @word_list_files do %>
        <div class="h-14 mx-auto flex flex-nowrap justify-between max-w-md odd:bg-gray-200 last:rounded-b-xl first:rounded-t-xl">
          <div class="pl-4 my-auto text-left">
            {display_file_name(word_list_file.file_name)}
          </div>
          <div class="my-auto pr-4">
            <%= if word_list_file.already_loaded? do %>
              <div class="flex">
                <div>
                  Known Words:
                </div>
                <div class="w-12 text-right">
                  {word_list_file.progress.review_count}/{word_list_file.progress.total_count}
                </div>
              </div>
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

  def display_file_name(file_name) do
    file_name
    |> String.trim_trailing(".csv")
    |> String.replace("-", " ")
    |> String.capitalize()
  end
end
