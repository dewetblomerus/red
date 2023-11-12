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
    cards = Card.for_user!(actor: user)

    loaded_cards =
      cards
      |> Enum.map(& &1.word)
      |> Enum.into(MapSet.new())

    review_words =
      cards
      |> Enum.filter(&(!is_nil(&1.retry_at)))
      |> Enum.filter(fn card ->
        DateTime.diff(card.retry_at, card.tried_at, :day) >= 1
      end)
      |> Enum.map(& &1.word)
      |> Enum.into(MapSet.new())

    Red.Words.lists()
    |> Enum.map(fn {file_name, word_list} ->
      is_already_loaded = already_loaded?(loaded_cards, word_list)

      %{
        file_name: file_name,
        already_loaded?: is_already_loaded,
        progress: progress(review_words, word_list, is_already_loaded)
      }
    end)
  end

  def progress(_, _, false), do: nil

  def progress(review_words, word_list, _) do
    review_count =
      word_list
      |> Enum.filter(fn %{word: word} ->
        Enum.member?(review_words, word)
      end)
      |> Enum.count()

    %{review_count: review_count, total_count: Enum.count(word_list)}
  end

  def already_loaded?(cards, word_list) do
    word_list
    |> Enum.map(& &1.word)
    |> Enum.all?(fn word ->
      Enum.member?(cards, word)
    end)
  end

  defp word_lists_dir() do
    "word_lists"
  end
end
