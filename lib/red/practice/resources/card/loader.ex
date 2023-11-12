defmodule Red.Practice.Card.Loader do
  alias Red.Practice.Card

  def load(user, file_name) do
    Red.Words.lists()
    |> Map.get(file_name)
    |> Enum.each(fn %{word: word, phrase: phrase} ->
      dbg("insterting word: '#{word}' for #{user.email} ⚠️")

      Red.Practice.Card.create(
        %{
          word: word,
          phrase: phrase
        },
        actor: user
      )
    end)
  end

  def list!(user) do
    cards =
      Card.for_user!(actor: user)
      |> Enum.map(& &1.word)
      |> Enum.into(MapSet.new())

    Red.Words.lists()
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(fn file_name ->
      %{
        file_name: file_name,
        already_loaded?: already_loaded?(cards, file_name)
      }
    end)
  end

  def already_loaded?(cards, file_name) do
    Red.Words.lists()
    |> Map.get(file_name)
    |> Enum.map(& &1.word)
    |> Enum.all?(fn word ->
      Enum.member?(cards, word)
    end)
  end

  defp word_lists_dir() do
    "word_lists"
  end
end
