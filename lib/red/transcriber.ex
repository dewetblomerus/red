defmodule Transcriber do
  require Req

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

    %Req.Response{status: 200, body: response_body} =
      Req.post!("https://api.openai.com/v1/audio/speech",
        json: body,
        headers: headers
      )

    File.write(filename, response_body)
  end
end
