defmodule Red.Audio.Transcriber do
  require Req
  alias ExAws.S3
  alias Red.Audio.Slugger

  @file_format "mp3"

  def transcribe(text) do
    if file_exists?(text) do
      {:ok, :already_exists}
    else
      with {:ok, file_contents} <- perform_transcription(text),
           upload_to_s3(text, file_contents) do
        {:ok, :uploaded}
      end
    end
  end

  def file_exists?(text) do
    perform_check =
      S3.head_object(
        "spellsightwords",
        "audio/#{Slugger.file_name(text, @file_format)}"
      )
      |> ExAws.request()

    case perform_check do
      {:ok, %{status_code: 200}} -> true
      {:error, {:http_error, 404, _}} -> false
    end
  end

  def perform_transcription(text) do
    headers = [
      {"Authorization", "Bearer #{openapi_key()}"},
      {"Content-Type", "application/json"}
    ]

    body = %{
      model: "tts-1-hd",
      input: text,
      voice: "echo",
      response_format: @file_format
    }

    %Req.Response{status: 200, body: file_contents} =
      Req.post!("https://api.openai.com/v1/audio/speech",
        json: body,
        headers: headers
      )

    {:ok, file_contents}
  end

  def upload_to_s3(text, file_contents) do
    %{status_code: 200} =
      S3.put_object(
        "spellsightwords",
        "audio/#{Slugger.file_name(text, @file_format)}",
        file_contents
      )
      |> ExAws.request!()
  end

  defp openapi_key do
    Application.fetch_env!(:red, :open_api_key)
  end
end
