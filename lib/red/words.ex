defmodule Red.Words do
  def lists do
    :persistent_term.get({__MODULE__, :wordlists})
  end

  def sort_word_lists(nil), do: nil

  def sort_word_lists(word_lists) do
    Enum.sort_by(word_lists, &get_book_number/1)
  end

  defp get_book_number(file_map) do
    file_map.file_name
    |> String.trim_trailing(".csv")
    |> String.split("-")
    |> List.last()
    |> String.to_integer()
  end
end
