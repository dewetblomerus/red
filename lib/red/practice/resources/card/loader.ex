defmodule Red.Practice.Card.Loader do
  # alias NimbleCSV.RFC4180

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
  end
end
