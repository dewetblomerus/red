defmodule Red.Words do
  def words do
    ["the", "red", "words"]
  end

  def random_word do
    words() |> Enum.random()
  end
end
