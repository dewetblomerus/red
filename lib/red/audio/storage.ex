defmodule Red.Audio.Storage do
  require Logger

  alias ExAws.S3

  @bucket "spellsightwords"
  @public_url_prefix "https://f000.backblazeb2.com/file/spellsightwords/audio/"

  def public_url(file_name), do: public_url_prefix() <> file_name

  def file_exists?(file_name) do
    Logger.info("Checking if file exists for: #{file_name}")

    bucket()
    |> S3.head_object("audio/#{file_name}")
    |> ExAws.request()
    |> case do
      {:ok, %{status_code: 200}} ->
        {:ok, true}

      {:error, {:http_error, 404, _}} ->
        {:ok, false}

      {:error, reason} ->
        Logger.warning(
          "Could not check audio file #{file_name}: #{inspect(reason)}"
        )

        {:error, reason}
    end
  rescue
    exception ->
      Logger.warning(
        "Could not check audio file #{file_name}: #{Exception.message(exception)}"
      )

      {:error, exception}
  end

  def upload(file_name, file_contents) do
    bucket()
    |> S3.put_object("audio/#{file_name}", file_contents)
    |> ExAws.request()
    |> case do
      {:ok, %{status_code: status}} when status in 200..299 ->
        :ok

      {:ok, %{status_code: status}} ->
        {:error, {:upload_http_error, status}}

      {:error, reason} ->
        Logger.warning(
          "Could not upload audio file #{file_name}: #{inspect(reason)}"
        )

        {:error, reason}
    end
  rescue
    exception ->
      Logger.warning(
        "Could not upload audio file #{file_name}: #{Exception.message(exception)}"
      )

      {:error, exception}
  end

  defp bucket do
    Application.get_env(:red, :audio_bucket, @bucket)
  end

  defp public_url_prefix do
    Application.get_env(:red, :audio_public_url_prefix, @public_url_prefix)
  end
end
