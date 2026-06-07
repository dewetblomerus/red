defmodule Red.Audio.OpenAI do
  require Logger

  @file_format "mp3"

  def perform_transcription(text) do
    with {:ok, api_key} <- openai_key() do
      Logger.info("Performing OpenAI transcription for: #{text}")

      body = %{
        model: "tts-1-hd",
        input: text,
        voice: "echo",
        response_format: @file_format
      }

      case Req.post("https://api.openai.com/v1/audio/speech",
             json: body,
             headers: headers(api_key)
           ) do
        {:ok, %Req.Response{status: 200, body: file_contents}} ->
          {:ok, file_contents}

        {:ok,
         %Req.Response{
           status: 429,
           body: %{"error" => %{"code" => "rate_limit_exceeded"}}
         }} ->
          Logger.warning("OpenAI rate limit exceeded, waiting 20 seconds")
          Process.sleep(20_000)
          perform_transcription(text)

        {:ok, %Req.Response{status: status, body: body}} ->
          Logger.warning(
            "OpenAI TTS failed with status #{status}: #{inspect(body)}"
          )

          {:error, {:provider_http_error, status}}

        {:error, reason} ->
          Logger.warning("OpenAI TTS request failed: #{inspect(reason)}")
          {:error, {:provider_request_error, reason}}
      end
    end
  end

  defp headers(api_key) do
    [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]
  end

  def voice_name, do: "echo"

  defp openai_key do
    case Application.get_env(:red, :open_api_key) ||
           System.get_env("OPENAI_API_KEY") do
      nil -> {:error, :missing_api_key}
      "" -> {:error, :missing_api_key}
      api_key -> {:ok, api_key}
    end
  end
end
