defmodule Red.Audio.Transcriber do
  require Logger

  alias Red.Audio.Slugger

  @file_format "mp3"

  def transcribe(word, phrase) do
    text = Slugger.audio_text(word, phrase)
    create_if_needed(text, provider().voice_name())
  end

  def audio_url(word, phrase) do
    text = Slugger.audio_text(word, phrase)
    file_name = file_name(text, provider().voice_name())

    storage().public_url(file_name)
  end

  def create_if_needed(text, voice) do
    file_name = file_name(text, voice)

    with {:ok, false} <- file_exists?(file_name),
         {:ok, file_contents} <- perform_transcription(text),
         :ok <- upload_to_s3(text, file_contents, file_name) do
      {:ok, :uploaded}
    else
      {:ok, true} -> {:ok, :already_exists}
      {:error, reason} -> {:error, reason}
    end
  end

  def file_exists?(file_name) do
    storage().file_exists?(file_name)
  end

  def perform_transcription(text) do
    provider().perform_transcription(text)
  end

  def upload_to_s3(text, file_contents, file_name) do
    Logger.info("Uploading file for: #{text}")

    storage().upload(file_name, file_contents)
  end

  defp file_name(text, voice) do
    Slugger.file_name(%{text: text, voice: voice, format: @file_format})
  end

  defp provider do
    Application.get_env(:red, :audio_tts_provider, Red.Audio.ElevenLabs)
  end

  defp storage do
    Application.get_env(:red, :audio_storage, Red.Audio.Storage)
  end
end
