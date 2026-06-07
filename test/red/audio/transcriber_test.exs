defmodule Red.Audio.TranscriberTest do
  use ExUnit.Case, async: false

  alias Red.Audio.Transcriber

  defmodule Provider do
    def voice_name, do: "test-voice"

    def perform_transcription(text) do
      send(self(), {:performed_transcription, text})

      case Process.get(:provider_result, {:ok, "audio-bytes"}) do
        {:ok, _} = result -> result
        {:error, _} = result -> result
      end
    end
  end

  defmodule Storage do
    def public_url(file_name), do: "https://example.test/audio/#{file_name}"

    def file_exists?(file_name) do
      send(self(), {:checked_file, file_name})
      Process.get(:file_exists_result, {:ok, false})
    end

    def upload(file_name, file_contents) do
      send(self(), {:uploaded_file, file_name, file_contents})
      Process.get(:upload_result, :ok)
    end
  end

  setup do
    old_provider = Application.get_env(:red, :audio_tts_provider)
    old_storage = Application.get_env(:red, :audio_storage)

    Application.put_env(:red, :audio_tts_provider, Provider)
    Application.put_env(:red, :audio_storage, Storage)

    on_exit(fn ->
      restore_env(:audio_tts_provider, old_provider)
      restore_env(:audio_storage, old_storage)
    end)
  end

  test "builds the public audio url" do
    assert Transcriber.audio_url("hello", "hello world") ==
             "https://example.test/audio/hello-as-in-hello-world-test-voice.mp3"
  end

  test "skips generation when the object already exists" do
    Process.put(:file_exists_result, {:ok, true})

    assert {:ok, :already_exists} =
             Transcriber.transcribe("hello", "hello world")

    assert_received {:checked_file, "hello-as-in-hello-world-test-voice.mp3"}
    refute_received {:performed_transcription, _}
    refute_received {:uploaded_file, _, _}
  end

  test "generates and uploads when the object is missing" do
    assert {:ok, :uploaded} =
             Transcriber.transcribe("hello", "hello world")

    assert_received {:checked_file, "hello-as-in-hello-world-test-voice.mp3"}
    assert_received {:performed_transcription, "Hello. As in, hello world"}

    assert_received {:uploaded_file, "hello-as-in-hello-world-test-voice.mp3",
                     "audio-bytes"}
  end

  test "returns storage check errors without generating" do
    Process.put(:file_exists_result, {:error, :missing_storage_credentials})

    assert {:error, :missing_storage_credentials} =
             Transcriber.transcribe("hello", "hello world")

    refute_received {:performed_transcription, _}
    refute_received {:uploaded_file, _, _}
  end

  test "returns provider errors without uploading" do
    Process.put(:provider_result, {:error, :missing_api_key})

    assert {:error, :missing_api_key} =
             Transcriber.transcribe("hello", "hello world")

    assert_received {:performed_transcription, "Hello. As in, hello world"}
    refute_received {:uploaded_file, _, _}
  end

  test "returns upload errors" do
    Process.put(:upload_result, {:error, :missing_storage_credentials})

    assert {:error, :missing_storage_credentials} =
             Transcriber.transcribe("hello", "hello world")

    assert_received {:uploaded_file, "hello-as-in-hello-world-test-voice.mp3",
                     "audio-bytes"}
  end

  defp restore_env(key, nil), do: Application.delete_env(:red, key)
  defp restore_env(key, value), do: Application.put_env(:red, key, value)
end
