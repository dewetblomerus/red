defmodule Red.Audio.Slugger do
  def slug(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]/, "-")
    |> String.trim("-")
    |> String.replace(~r/-+/, "-")
  end

  def file_name(text, format) do
    slug(text) <> "." <> format
  end

  def file_name(word, phrase, format) do
    text = audio_text(word, phrase)
    slug(text) <> "." <> format
  end

  def audio_text(word, phrase) do
    "#{String.capitalize(word)}. As in, #{phrase}"
  end
end
