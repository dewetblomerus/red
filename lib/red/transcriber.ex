defmodule Transcriber do
  require Req
  alias ExAws.S3

  def transcribe(text, filename) do
    api_key = Application.fetch_env!(:red, :open_api_key)

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    body = %{
      model: "tts-1-hd",
      input: text,
      voice: "echo",
      response_format: "opus"
    }

    %Req.Response{status: 200, body: file_contents} =
      Req.post!("https://api.openai.com/v1/audio/speech",
        json: body,
        headers: headers
      )

    S3.put_object("spellsightwords", "audio/#{filename}", file_contents)
    |> ExAws.request!()
  end
end
