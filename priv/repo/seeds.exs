# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Red.Repo.insert!(%Red.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias NimbleCSV.RFC4180, as: CSV

email = "dewetblomerus+new@gmail.com"
user = Red.Accounts.User.get_by!(%{email: email})

NimbleCSV.define(MyParser, separator: "|", escape: "\"")

"priv/repo/book_1_to_3_seeds.csv"
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
