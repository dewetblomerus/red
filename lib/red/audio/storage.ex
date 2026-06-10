defmodule Red.Audio.Storage do
  require Logger

  alias ExAws.S3

  def public_url(file_name), do: public_url_prefix() <> file_name

  def exists?(file_name) do
    bucket()
    |> S3.head_object("audio/#{file_name}")
    |> request()
    |> case do
      {:ok, %{status_code: status}} when status in 200..299 ->
        {:ok, true}

      {:error, {:http_error, 404, _body}} ->
        {:ok, false}

      {:ok, %{status_code: 404}} ->
        {:ok, false}

      {:ok, %{status_code: status}} ->
        {:error, {:exists_http_error, status}}

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
    |> request()
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
    Application.fetch_env!(:red, :audio_bucket)
  end

  defp public_url_prefix do
    Application.fetch_env!(:red, :audio_public_url_prefix)
  end

  defp request(operation) do
    operation
    |> ExAws.Operation.perform(backblaze_config())
  end

  defp backblaze_config do
    config = ExAws.Config.new(:s3)
    host = Map.fetch!(config, :host)

    Map.put(config, :region, backblaze_region!(host))
  end

  defp backblaze_region!("s3." <> rest) do
    case String.split(rest, ".", parts: 2) do
      [region, "backblazeb2.com"] ->
        region

      _ ->
        raise "BACKBLAZE_B2_S3_HOST must look like s3.<region>.backblazeb2.com"
    end
  end

  defp backblaze_region!(_host) do
    raise "BACKBLAZE_B2_S3_HOST must look like s3.<region>.backblazeb2.com"
  end
end
