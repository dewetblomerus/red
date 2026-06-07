defmodule Red.Audio.ElevenLabs do
  require Logger

  @output_format "mp3_44100_128"
  @voice_id "JBFqnCBsd6RMkjVDRZzb"
  @voice_name "george"
  @model_id "eleven_multilingual_v2"

  def voice_name, do: @voice_name

  def perform_transcription(text, opts \\ []) do
    with {:ok, api_key} <- api_key() do
      post = Keyword.get(opts, :post, &Req.post/2)

      url =
        "https://api.elevenlabs.io/v1/text-to-speech/#{voice_id()}?output_format=#{@output_format}"

      body = %{
        text: text,
        model_id: @model_id
      }

      case post.(url, json: body, headers: headers(api_key)) do
        {:ok, %Req.Response{status: 200, body: file_contents}} ->
          {:ok, file_contents}

        {:ok, %Req.Response{status: status, body: body}} ->
          Logger.warning(
            "ElevenLabs TTS failed with status #{status}: #{inspect(body)}"
          )

          {:error, {:provider_http_error, status}}

        {:error, reason} ->
          Logger.warning("ElevenLabs TTS request failed: #{inspect(reason)}")
          {:error, {:provider_request_error, reason}}
      end
    end
  end

  defp headers(api_key) do
    [
      {"xi-api-key", api_key},
      {"Content-Type", "application/json"}
    ]
  end

  defp api_key do
    case Application.get_env(:red, :elevenlabs_api_key) ||
           System.get_env("ELEVENLABS_API_KEY") do
      nil -> {:error, :missing_api_key}
      "" -> {:error, :missing_api_key}
      api_key -> {:ok, api_key}
    end
  end

  defp voice_id do
    Application.get_env(:red, :elevenlabs_voice_id, @voice_id)
  end
end
