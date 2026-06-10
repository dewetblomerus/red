defmodule Red.Audio.Generator do
  require Logger

  alias Red.Audio.Slugger
  alias Red.Words

  def audio_url(word, phrase) do
    file_name = object_key(word, phrase)

    audio_public_url_prefix() <> file_name
  end

  def file_name(word, phrase) do
    Slugger.file_name(%{
      word: word,
      phrase: phrase,
      format: audio_file_format()
    })
  end

  def object_key(word, phrase) do
    Path.join([audio_provider_path(), file_name(word, phrase)])
  end

  def generate(word) do
    case find_word(word) do
      {:ok, %{word: word, phrase: phrase}} -> generate(word, phrase)
      {:error, reason} -> {:error, reason}
    end
  end

  def generate(word, phrase) do
    text = Slugger.audio_text(word, phrase)
    object_key = object_key(word, phrase)

    with {:ok, file_contents} <- generate_audio(word, phrase),
         :ok <- upload(text, file_contents, object_key) do
      {:ok, :uploaded}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def generate_all do
    Words.lists()
    |> entries()
    |> Enum.map(fn %{word: word, phrase: phrase} ->
      {word, generate(word, phrase)}
    end)
  end

  defp find_word(word) do
    Words.lists()
    |> entries()
    |> Enum.find(fn %{word: list_word} ->
      String.downcase(list_word) == String.downcase(word)
    end)
    |> case do
      nil -> {:error, {:word_not_found, word}}
      entry -> {:ok, entry}
    end
  end

  defp entries(word_lists) do
    word_lists
    |> Map.values()
    |> List.flatten()
    |> Enum.uniq_by(fn %{word: word, phrase: phrase} -> {word, phrase} end)
  end

  defp generate_audio(word, phrase) do
    text = elevenlabs_audio_text(word, phrase)

    Logger.notice("Sending audio text to ElevenLabs: #{text}")

    audio_tts_provider().generate_audio(text)
  end

  defp elevenlabs_audio_text(word, phrase) do
    Slugger.audio_text(word, phrase)
  end

  defp upload(text, file_contents, file_name) do
    Logger.info("Uploading file for: #{text}")

    audio_storage().upload(file_name, file_contents)
  end

  defp audio_tts_provider, do: Application.fetch_env!(:red, :audio_tts_provider)
  defp audio_storage, do: Application.fetch_env!(:red, :audio_storage)
  defp audio_file_format, do: Application.fetch_env!(:red, :audio_file_format)

  defp audio_provider_path do
    Application.fetch_env!(:red, :audio_provider_path)
  end

  defp audio_public_url_prefix do
    Application.fetch_env!(:red, :audio_public_url_prefix)
  end
end
