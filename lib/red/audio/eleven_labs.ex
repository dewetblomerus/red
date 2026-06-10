defmodule Red.Audio.ElevenLabs do
  require Logger

  def generate_audio(text, opts \\ []) do
    with {:ok, api_key} <- api_key() do
      post = Keyword.get(opts, :post, &Req.post/2)

      url =
        "https://api.elevenlabs.io/v1/text-to-speech/#{voice_id()}?output_format=#{output_format()}"

      body = %{
        text: text,
        model_id: model_id(),
        voice_settings: voice_settings()
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
    case Application.fetch_env!(:red, :elevenlabs_api_key) do
      nil -> {:error, :missing_api_key}
      "" -> {:error, :missing_api_key}
      api_key -> {:ok, api_key}
    end
  end

  defp voice_id do
    Application.fetch_env!(:red, :elevenlabs_voice_id)
  end

  defp model_id, do: Application.fetch_env!(:red, :elevenlabs_model_id)

  defp voice_settings do
    %{
      stability: 1,
      similarity_boost: 1,
      style: 0,
      use_speaker_boost: true,
      speed: 1
    }
  end

  defp output_format do
    Application.fetch_env!(:red, :elevenlabs_output_format)
  end
end
