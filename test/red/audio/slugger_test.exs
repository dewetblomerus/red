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
    assert Slugger.file_name(%{
             word: "hello",
             phrase: "hello world",
             voice: "connory",
             format: "opus"
           }) == "hello-as-in-hello-world-connory.opus"

    assert Slugger.file_name(%{
             word: "cookie",
             phrase: "Do you want a cookie?",
             voice: "connory",
             format: "opus"
           }) == "cookie-as-in-do-you-want-a-cookie-connory.opus"

    assert Slugger.file_name(%{
             word: "how",
             phrase: "How do, you do?",
             voice: "connory",
             format: "opus"
           }) == "how-as-in-how-do-you-do-connory.opus"

    assert Slugger.file_name(%{
             word: "many",
             phrase: "many       spaces",
             voice: "connory",
             format: "opus"
           }) == "many-as-in-many-spaces-connory.opus"
  end
end
