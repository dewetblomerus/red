defmodule Red.Audio.ElevenLabsTest do
  use ExUnit.Case, async: false

  alias Red.Audio.ElevenLabs

  setup do
    old_api_key = Application.get_env(:red, :elevenlabs_api_key)
    old_voice_id = Application.get_env(:red, :elevenlabs_voice_id)

    on_exit(fn ->
      restore_env(:elevenlabs_api_key, old_api_key)
      restore_env(:elevenlabs_voice_id, old_voice_id)
    end)
  end

  test "returns an error when the api key is missing" do
    Application.put_env(:red, :elevenlabs_api_key, "")

    assert {:error, :missing_api_key} =
             ElevenLabs.generate_audio("Hello. As in, hello world")
  end

  test "returns generated audio from a successful response" do
    Application.put_env(:red, :elevenlabs_api_key, "test-key")
    Application.put_env(:red, :elevenlabs_voice_id, "voice-id")

    post = fn url, opts ->
      assert url ==
               "https://api.elevenlabs.io/v1/text-to-speech/voice-id?output_format=mp3_44100_128"

      assert opts[:json] == %{
               text: "Hello. As in, hello world",
               model_id: "eleven_v3",
               voice_settings: %{
                 stability: 1,
                 similarity_boost: 1,
                 style: 0,
                 use_speaker_boost: true,
                 speed: 1
               }
             }

      assert {"xi-api-key", "test-key"} in opts[:headers]

      {:ok, %Req.Response{status: 200, body: "audio-bytes"}}
    end

    assert {:ok, "audio-bytes"} =
             ElevenLabs.generate_audio("Hello. As in, hello world",
               post: post
             )
  end

  defp restore_env(key, nil), do: Application.delete_env(:red, key)
  defp restore_env(key, value), do: Application.put_env(:red, key, value)
end
