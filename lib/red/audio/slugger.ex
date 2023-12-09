defmodule Red.Audio.Slugger do
  def slug(phrase) do
    phrase
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]/, "-")
    |> String.trim("-")
    |> String.replace(~r/-+/, "-")
  end

  def file_name(phrase, format) do
    slug(phrase) <> "." <> format
  end
end
