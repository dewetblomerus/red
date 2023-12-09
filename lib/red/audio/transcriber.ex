defmodule Red.Audio.Transcriber do
  require Req
  alias ExAws.S3
  alias Red.Audio.Slugger

  @file_format "mp3"

  def transcribe(text) do
    api_key = Application.fetch_env!(:red, :open_api_key)

    headers = [
      {"Authorization", "Bearer #{api_key}"},
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

    %{status_code: 200} =
      S3.put_object(
        "spellsightwords",
        "audio/#{Slugger.file_name(text, @file_format)}",
        file_contents
      )
      |> ExAws.request!()
  end
end
