defmodule Red.WordsTest do
  use ExUnit.Case, async: true

  describe "sort_word_lists/1" do
    test "sorts word lists by book number" do
      word_lists = [
        %{file_name: "book-3.csv"},
        %{file_name: "book-1.csv"},
        %{file_name: "book-2.csv"}
      ]

      assert Red.Words.sort_word_lists(word_lists) == [
               %{file_name: "book-1.csv"},
               %{file_name: "book-2.csv"},
               %{file_name: "book-3.csv"}
             ]
    end

    test "hands back nil" do
      assert Red.Words.sort_word_lists(nil) == nil
    end
  end
end
