defmodule RedWeb.PracticeLiveTest do
  use Red.DataCase, async: true
  alias Red.Factory
  alias Red.Practice.Card
  alias RedWeb.PracticeLive

  describe "get_next_card/1" do
    test "returns nil when Card.next returns NotFound error" do
      user = Factory.user_factory()

      # When there are no cards, Card.next should return NotFound error
      # and get_next_card should handle it gracefully by returning nil
      assert PracticeLive.get_next_card(user) == nil
    end

    test "returns card when Card.next succeeds" do
      user = Factory.user_factory()
      card = Factory.card_factory(user)

      result = PracticeLive.get_next_card(user)
      assert result.id == card.id
    end
  end

  describe "no cards scenario" do
    test "handles the complete flow when there are no cards available" do
      user = Factory.user_factory()

      # Verify that Card.next returns the expected error structure
      assert {:error, %Ash.Error.Invalid{errors: [%Ash.Error.Query.NotFound{}]}} =
               Card.next(actor: user)

      # Verify that get_next_card handles this error gracefully
      assert PracticeLive.get_next_card(user) == nil

      # This test ensures that the PracticeLive module can handle the scenario
      # where Card.next starts returning a new result (NotFound error) without crashing
    end
  end

  describe "handle_info/2 with :say" do
    test "does nothing when no card is assigned" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{card: nil}
      }

      assert {:noreply, ^socket} = PracticeLive.handle_info(:say, socket)
    end

    test "pushes Say event when card is assigned" do
      card = %{word: "test", phrase: "test phrase"}

      socket = %Phoenix.LiveView.Socket{
        assigns: %{card: card}
      }

      {:noreply, result_socket} = PracticeLive.handle_info(:say, socket)

      # The socket should have the push_event applied
      assert result_socket != socket
    end
  end

  describe "success_streak/2" do
    test "returns correct emoji pattern for success streak" do
      result = PracticeLive.success_streak(3, 5)

      # Should have 3 emojis and 2 blanks
      assert length(result) == 5

      # First 3 should be emojis (not "_")
      emojis = Enum.take(result, 3)
      assert Enum.all?(emojis, fn item -> item != "_" end)

      # Last 2 should be blanks
      blanks = Enum.drop(result, 3)
      assert blanks == ["_", "_"]
    end

    test "returns all emojis when goal is met" do
      result = PracticeLive.success_streak(5, 5)

      # Should have 5 emojis and no blanks
      assert length(result) == 5
      assert Enum.all?(result, fn item -> item != "_" end)
    end

    test "returns all blanks when no success" do
      result = PracticeLive.success_streak(0, 3)

      # Should have 3 blanks
      assert result == ["_", "_", "_"]
    end
  end
end
