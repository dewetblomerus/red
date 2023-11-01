defmodule Red.Practice.Card.Loader do
  alias Red.Practice.Card
  NimbleCSV.define(MyParser, separator: "|", escape: "\"")

  def load(user, file_name) do
    "#{word_lists_dir()}/#{file_name}"
    |> File.stream!()
    |> MyParser.parse_stream()
    |> Stream.map(fn [word, phrase] ->
      dbg("insterting word: '#{word}' for #{user.email} ⚠️")

      Red.Practice.Card.create(
        %{
          word: word,
          phrase: phrase
        },
        actor: user
      )
    end)
    |> Stream.run()
  end

  def list!(user) do
    word_lists_dir()
    |> File.ls!()
    |> Enum.sort()
    |> Enum.map(fn file_name ->
      %{
        file_name: file_name,
        already_loaded?: already_loaded?(user, file_name)
      }
    end)
  end

  def already_loaded?(user, file_name) do
    "#{word_lists_dir()}/#{file_name}"
    |> File.stream!()
    |> MyParser.parse_stream()
    |> Enum.all?(fn [word, _] ->
      result = Red.Practice.Card.get_by(%{word: word}, actor: user)
      match?({:ok, _}, result) |> dbg()
    end)
  end

  defp get_next_card(user) do
    case Card.next(actor: user) do
      {:ok, card} ->
        card

      {:error, %Ash.Error.Query.NotFound{}} ->
        nil
    end
  end

  defp word_lists_dir() do
    "word_lists"
  end
end
