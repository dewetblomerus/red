defmodule Red.Practice.Card.Loader do
  alias Red.Practice.Card

  def call(user) do
    NimbleCSV.define(MyParser, separator: "|", escape: "\"")

    "word_lists/book_1_to_3.csv"
    |> File.stream!()
    |> MyParser.parse_stream()
    |> Stream.map(fn [word, phrase] ->
      Red.Practice.Card.create(
        %{
          word: word,
          phrase: phrase
        },
        actor: user
      )
    end)
    |> Stream.run()

    get_next_card(user)
  end

  defp get_next_card(user) do
    case Card.next(actor: user) do
      {:ok, card} ->
        card

      {:error, %Ash.Error.Query.NotFound{}} ->
        nil
    end
  end
end
