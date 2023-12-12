defmodule Red.Audio.OpenApi do
  require Logger

  @file_format "opus"

  def perform_transcription(text) do
    Logger.info("Performing transcription for: #{text} 💬")

    body = %{
      model: "tts-1-hd",
      input: text,
      voice: "echo",
      response_format: @file_format
    }

    response =
      Req.post!("https://api.openai.com/v1/audio/speech",
        json: body,
        headers: headers()
      )

    case response do
      %Req.Response{status: 200, body: file_contents} ->
        {:ok, file_contents}

      %Req.Response{
        status: 429,
        body: %{"error" => %{"code" => "rate_limit_exceeded"}}
      } ->
        Logger.warning("Rate limit exceeded ⚠️, waiting 20 seconds ⏳")
        Process.sleep(20_000)
        Logger.warning("Retrying transcription 🔄")
        perform_transcription(text)
    end
  end

  defp headers do
    [
      {"Authorization", "Bearer #{openapi_key()}"},
      {"Content-Type", "application/json"}
    ]
  end

  def voices do
    ~w(alloy echo fable onyx nova shimmer)
  end

  defp openapi_key do
    Application.fetch_env!(:red, :open_api_key)
  end
end
