defmodule Red.Audio.GeneratorTest do
  use ExUnit.Case, async: false

  alias Red.Audio.Generator

  defmodule Provider do
    def generate_audio(text) do
      send(self(), {:generated_audio, text})

      case Process.get(:provider_result, {:ok, "audio-bytes"}) do
        {:ok, _} = result -> result
        {:error, _} = result -> result
      end
    end
  end

  defmodule Storage do
    def upload(file_name, file_contents) do
      send(self(), {:uploaded_file, file_name, file_contents})
      Process.get(:upload_result, :ok)
    end
  end

  setup do
    old_provider = Application.get_env(:red, :audio_tts_provider)
    old_storage = Application.get_env(:red, :audio_storage)
    old_voice_name = Application.get_env(:red, :audio_voice_name)
    old_provider_path = Application.get_env(:red, :audio_provider_path)
    old_public_url_prefix = Application.get_env(:red, :audio_public_url_prefix)

    Application.put_env(:red, :audio_tts_provider, Provider)
    Application.put_env(:red, :audio_storage, Storage)
    Application.put_env(:red, :audio_voice_name, "test-voice")

    Application.put_env(
      :red,
      :audio_provider_path,
      "test-provider/test-version/test-voice"
    )

    Application.put_env(
      :red,
      :audio_public_url_prefix,
      "https://example.test/audio/"
    )

    on_exit(fn ->
      restore_env(:audio_tts_provider, old_provider)
      restore_env(:audio_storage, old_storage)
      restore_env(:audio_voice_name, old_voice_name)
      restore_env(:audio_provider_path, old_provider_path)
      restore_env(:audio_public_url_prefix, old_public_url_prefix)
    end)
  end

  test "builds the public audio url" do
    assert Generator.audio_url("hello", "hello world") ==
             "https://example.test/audio/test-provider/test-version/test-voice/hello-as-in-hello-world-test-voice.mp3"
  end

  test "builds the storage object key" do
    assert Generator.object_key("hello", "hello world") ==
             "test-provider/test-version/test-voice/hello-as-in-hello-world-test-voice.mp3"
  end

  test "generates a word from the loaded word lists" do
    assert {:ok, :uploaded} = Generator.generate("have")

    assert_received {:generated_audio, "[clearly] Have. As in, I have a dog"}

    assert_received {:uploaded_file,
                     "test-provider/test-version/test-voice/have-as-in-i-have-a-dog-test-voice.mp3",
                     "audio-bytes"}
  end

  test "returns an error when a word is not in the loaded word lists" do
    assert {:error, {:word_not_found, "not-a-real-word"}} =
             Generator.generate("not-a-real-word")

    refute_received {:generated_audio, _}
    refute_received {:uploaded_file, _, _}
  end

  test "generates and uploads" do
    assert {:ok, :uploaded} = Generator.generate("hello", "hello world")

    assert_received {:generated_audio, "[clearly] Hello. As in, hello world"}

    assert_received {:uploaded_file,
                     "test-provider/test-version/test-voice/hello-as-in-hello-world-test-voice.mp3",
                     "audio-bytes"}
  end

  test "formats ElevenLabs text with a v3 audio tag" do
    assert {:ok, :uploaded} =
             Generator.generate("cookie", "can I have a cookie?")

    assert_received {:generated_audio,
                     "[clearly] Cookie. As in, can I have a cookie?"}
  end

  test "returns provider errors without uploading" do
    Process.put(:provider_result, {:error, :missing_api_key})

    assert {:error, :missing_api_key} =
             Generator.generate("hello", "hello world")

    assert_received {:generated_audio, "[clearly] Hello. As in, hello world"}

    refute_received {:uploaded_file, _, _}
  end

  test "returns upload errors" do
    Process.put(:upload_result, {:error, :missing_storage_credentials})

    assert {:error, :missing_storage_credentials} =
             Generator.generate("hello", "hello world")

    assert_received {:uploaded_file,
                     "test-provider/test-version/test-voice/hello-as-in-hello-world-test-voice.mp3",
                     "audio-bytes"}
  end

  test "generates all loaded word-list entries" do
    results = Generator.generate_all()

    assert {"a", {:ok, :uploaded}} in results

    assert_received {:uploaded_file,
                     "test-provider/test-version/test-voice/a-as-in-do-you-want-a-cookie-test-voice.mp3",
                     _}
  end

  defp restore_env(key, nil), do: Application.delete_env(:red, key)
  defp restore_env(key, value), do: Application.put_env(:red, key, value)
end
