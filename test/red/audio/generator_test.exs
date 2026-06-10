defmodule Red.Audio.GeneratorTest do
  use ExUnit.Case, async: false

  alias Red.Audio.Generator

  defmodule Provider do
    def generate_audio(text) do
      send(test_pid(), {:generated_audio, text})

      case Process.get(:provider_result, {:ok, "audio-bytes"}) do
        {:ok, _} = result -> result
        {:error, _} = result -> result
      end
    end

    defp test_pid do
      Application.get_env(:red, :audio_test_pid, self())
    end
  end

  defmodule Storage do
    def exists?(file_name) do
      send(test_pid(), {:checked_file, file_name})
      {:ok, Process.get(:file_exists?, false)}
    end

    def upload(file_name, file_contents) do
      send(test_pid(), {:uploaded_file, file_name, file_contents})
      Process.get(:upload_result, :ok)
    end

    defp test_pid do
      Application.get_env(:red, :audio_test_pid, self())
    end
  end

  setup do
    old_test_pid = Application.get_env(:red, :audio_test_pid)
    old_provider = Application.get_env(:red, :audio_tts_provider)
    old_storage = Application.get_env(:red, :audio_storage)
    old_provider_path = Application.get_env(:red, :audio_provider_path)
    old_public_url_prefix = Application.get_env(:red, :audio_public_url_prefix)

    Application.put_env(:red, :audio_test_pid, self())
    Application.put_env(:red, :audio_tts_provider, Provider)
    Application.put_env(:red, :audio_storage, Storage)

    Application.put_env(
      :red,
      :audio_provider_path,
      "test-provider/test-model/test-voice"
    )

    Application.put_env(
      :red,
      :audio_public_url_prefix,
      "https://example.test/audio/"
    )

    on_exit(fn ->
      restore_env(:audio_test_pid, old_test_pid)
      restore_env(:audio_tts_provider, old_provider)
      restore_env(:audio_storage, old_storage)
      restore_env(:audio_provider_path, old_provider_path)
      restore_env(:audio_public_url_prefix, old_public_url_prefix)
    end)
  end

  test "builds the public audio url" do
    assert Generator.audio_url("hello", "hello world") ==
             "https://example.test/audio/test-provider/test-model/test-voice/hello-as-in-hello-world.mp3"
  end

  test "builds the storage object key" do
    assert Generator.object_key("hello", "hello world") ==
             "test-provider/test-model/test-voice/hello-as-in-hello-world.mp3"
  end

  test "generates a word from the loaded word lists" do
    assert {:ok, :uploaded} = Generator.generate("have")

    assert_received {:generated_audio, "Have. As in, I have a dog"}

    assert_received {:uploaded_file,
                     "test-provider/test-model/test-voice/have-as-in-i-have-a-dog.mp3",
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

    assert_received {:checked_file,
                     "test-provider/test-model/test-voice/hello-as-in-hello-world.mp3"}

    assert_received {:generated_audio, "Hello. As in, hello world"}

    assert_received {:uploaded_file,
                     "test-provider/test-model/test-voice/hello-as-in-hello-world.mp3",
                     "audio-bytes"}
  end

  test "skips generation when the audio file already exists" do
    Process.put(:file_exists?, true)

    assert {:ok, :already_exists} =
             Generator.generate("hello", "hello world")

    assert_received {:checked_file,
                     "test-provider/test-model/test-voice/hello-as-in-hello-world.mp3"}

    refute_received {:generated_audio, _}
    refute_received {:uploaded_file, _, _}
  end

  test "formats ElevenLabs text without a v3 audio tag" do
    assert {:ok, :uploaded} =
             Generator.generate("cookie", "can I have a cookie?")

    assert_received {:generated_audio, "Cookie. As in, can I have a cookie?"}
  end

  test "returns provider errors without uploading" do
    Process.put(:provider_result, {:error, :missing_api_key})

    assert {:error, :missing_api_key} =
             Generator.generate("hello", "hello world")

    assert_received {:generated_audio, "Hello. As in, hello world"}

    refute_received {:uploaded_file, _, _}
  end

  test "returns upload errors" do
    Process.put(:upload_result, {:error, :missing_storage_credentials})

    assert {:error, :missing_storage_credentials} =
             Generator.generate("hello", "hello world")

    assert_received {:uploaded_file,
                     "test-provider/test-model/test-voice/hello-as-in-hello-world.mp3",
                     "audio-bytes"}
  end

  test "generates all loaded word-list entries" do
    results = Generator.generate_all()

    assert {"a", {:ok, :uploaded}} in results

    assert_received {:uploaded_file,
                     "test-provider/test-model/test-voice/a-as-in-do-you-want-a-cookie.mp3",
                     _}
  end

  defp restore_env(key, nil), do: Application.delete_env(:red, key)
  defp restore_env(key, value), do: Application.put_env(:red, key, value)
end
