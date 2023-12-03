defmodule Red.Practice.CardTest do
  use Red.DataCase, async: true
  alias Red.Practice.Card
  alias Red.Factory

  setup do
    user = Red.Factory.user_factory()
    %{user: user}
  end

  describe "create/1" do
    test "creates a new card", %{user: user} do
      assert {:ok,
              %Card{
                correct_streak: 0,
                phrase: "phrase",
                retry_at: nil,
                tried_at: nil,
                word: "word"
              }} =
               Card.create(
                 %{
                   phrase: "phrase",
                   word: "word"
                 },
                 actor: user
               )
    end
  end

  describe "try" do
    test "requires a retry when incorrect", %{user: user} do
      {:ok, card} =
        Card.create(
          %{
            phrase: "phrase",
            word: "word"
          },
          actor: user
        )

      tried_card =
        card
        |> Ash.Changeset.for_update(:try, %{tried_spelling: "untried"},
          actor: user
        )
        |> Red.Practice.update!()

      assert %Card{
               correct_streak: 0,
               phrase: "phrase",
               retry_at: retry_at,
               tried_at: tried_at,
               word: "word"
             } = tried_card

      assert retry_at == tried_at
    end
  end

  describe "next/1" do
    test "returns an error when there are no cards", %{user: user} do
      assert {:error, %Ash.Error.Query.NotFound{}} = Card.next(actor: user)
    end

    test "when there are cards due, returns the oldest due card", %{user: user} do
      now = NaiveDateTime.utc_now()
      two_minutes_ago = NaiveDateTime.add(now, -2, :minute)
      three_minutes_ago = NaiveDateTime.add(now, -3, :minute)

      _another_due_card =
        Factory.card_factory(
          user,
          %{
            retry_at: two_minutes_ago
          }
        )

      oldest_due_card =
        Factory.card_factory(
          user,
          %{
            retry_at: three_minutes_ago
          }
        )

      assert {:ok, next_card} = Card.next(actor: user)
      assert next_card.id == oldest_due_card.id
    end

    test "returns the oldest untried card", %{user: user} do
      now = NaiveDateTime.utc_now()
      two_minutes_ago = NaiveDateTime.add(now, -2, :minute)
      three_minutes_ago = NaiveDateTime.add(now, -3, :minute)

      oldest_card =
        Factory.card_factory(
          user,
          %{
            created_at: two_minutes_ago
          }
        )

      _newer_card =
        Factory.card_factory(
          user,
          %{
            created_at: three_minutes_ago
          }
        )

      assert oldest_card.id == Card.next!(actor: user).id
    end
  end
end
