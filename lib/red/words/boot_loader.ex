defmodule Red.Words.BootLoader do
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :transient,
      shutdown: 500
    }
  end

  def start_link do
    Task.start_link(fn ->
      dbg("🏃‍♂️ Running once at startup 🏃‍♂️")
      load()
    end)
  end

  def load() do
    all_word_lists =
      word_lists_dir()
      |> File.ls!()
      |> Enum.sort()
      |> Enum.into(%{}, fn filename ->
        {filename, readfile(filename)}
      end)

    :persistent_term.put({Red.Words, :wordlists}, all_word_lists)
  end

  NimbleCSV.define(MyParser, separator: "|", escape: "\"")

  def readfile(file_name) do
    "#{word_lists_dir()}/#{file_name}"
    |> File.stream!()
    |> MyParser.parse_stream()
    |> Stream.map(fn [word, phrase] ->
      %{word: word, phrase: phrase}
    end)
    |> Enum.to_list()
  end

  defp word_lists_dir() do
    "word_lists"
  end
end
