defmodule Red.Audio.Transcriber do
  require Req
  require Logger
  alias ExAws.S3
  alias Red.Audio.Slugger
  alias Red.Audio.OpenApi

  @file_format "opus"

  def transcribe(word, phrase) do
    text = Slugger.audio_text(word, phrase)
    voices = OpenApi.voices()

    voices
    |> Enum.each(fn voice ->
      create_if_needed(text, voice)
    end)
  end

  def create_if_needed(text, voice) do
    file_name =
      Slugger.file_name(%{text: text, voice: voice, format: @file_format})

    if file_exists?(file_name) do
      {:ok, :already_exists}
    else
      with {:ok, file_contents} <- perform_transcription(text),
           upload_to_s3(text, file_contents, file_name) do
        {:ok, :uploaded}
      end
    end
  end

  def file_exists?(file_name) do
    Logger.info("Checking if file exists for: #{file_name} ✅")

    check_result =
      S3.head_object("spellsightwords", "audio/#{file_name}")
      |> ExAws.request()

    case check_result do
      {:ok, %{status_code: 200}} ->
        Logger.info("#{file_name} exists ✅")
        true

      {:error, {:http_error, 404, _}} ->
        Logger.info("#{file_name} not found ⚠️")
        false
    end
  end

  def perform_transcription(text) do
    OpenApi.perform_transcription(text)
  end

  def upload_to_s3(text, file_contents, file_name) do
    Logger.info("Uploading file for: #{text} 🛢️")

    %{status_code: 200} =
      S3.put_object(
        "spellsightwords",
        "audio/#{file_name}",
        file_contents
      )
      |> ExAws.request!()
  end
end
