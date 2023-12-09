defmodule Red.Audio.SluggerTest do
  use ExUnit.Case, async: true
  alias Red.Audio.Slugger

  test "slug/1" do
    assert Slugger.slug("hello world") == "hello-world"
    assert Slugger.slug("Do you want a cookie?") == "do-you-want-a-cookie"
    assert Slugger.slug("How do, you do?") == "how-do-you-do"
    assert Slugger.slug("many       spaces") == "many-spaces"
  end

  test "file_name/2" do
    assert Slugger.file_name("hello world", "mp3") == "hello-world.mp3"

    assert Slugger.file_name("Do you want a cookie?", "mp3") ==
             "do-you-want-a-cookie.mp3"

    assert Slugger.file_name("How do, you do?", "mp3") == "how-do-you-do.mp3"
    assert Slugger.file_name("many       spaces", "mp3") == "many-spaces.mp3"
  end
end
