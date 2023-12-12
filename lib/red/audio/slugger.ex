defmodule Red.Audio.Slugger do
  def slug(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]/, "-")
    |> String.trim("-")
    |> String.replace(~r/-+/, "-")
  end

  def file_name(%{text: text, voice: voice, format: format}) do
    slug(text) <> "-" <> voice <> "." <> format
  end

  def file_name(%{
        word: word,
        phrase: phrase,
        voice: voice,
        format: format
      }) do
    text = audio_text(word, phrase)
    file_name(%{text: text, voice: voice, format: format})
  end

  def audio_text(word, phrase) do
    "#{String.capitalize(word)}. As in, #{phrase}"
  end
end
