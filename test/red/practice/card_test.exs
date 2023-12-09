defmodule Red.Practice.CardTest do
  use Red.DataCase, async: true
  alias Red.Factory
  alias Red.Practice.Card

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

    test "when there are no cards due returns the oldest untried card", %{
      user: user
    } do
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

    test "when there are no cards due, before hitting daily goal, get oldest untried card",
         %{user: user} do
      now = NaiveDateTime.utc_now()
      nineteen_minutes_from_now = NaiveDateTime.add(now, 19, :minute)

      oldest_card =
        Factory.card_factory(user)

      near_future_card =
        Factory.card_factory(
          user,
          %{
            retry_at: nineteen_minutes_from_now
          }
        )

      assert oldest_card.id == Card.next!(actor: user).id
    end

    test "when there are no cards due, after hitting daily goal, look ahead 20 mintues",
         %{user: user} do
      now = NaiveDateTime.utc_now()
      nineteen_minutes_from_now = NaiveDateTime.add(now, 19, :minute)

      oldest_card =
        Factory.card_factory(user)

      for _ <- 1..user.daily_goal do
        Factory.card_factory(
          user,
          %{
            tried_at: NaiveDateTime.utc_now()
          }
        )
      end

      near_future_card =
        Factory.card_factory(
          user,
          %{
            retry_at: nineteen_minutes_from_now
          }
        )

      assert near_future_card.id == Card.next!(actor: user).id
    end
  end

  describe "interval" do
    test "returns the correct interval for a card with rety_at and tried_at", %{
      user: user
    } do
      now = NaiveDateTime.utc_now()
      ten_minutes_from_now = NaiveDateTime.add(now, 10, :minute)

      card =
        Factory.card_factory(
          user,
          %{
            retry_at: ten_minutes_from_now,
            tried_at: now
          }
        )

      loaded_card =
        Red.Practice.load!(card, [
          :interval
        ])

      assert 600 == loaded_card.interval
    end

    test "returns the nil for a card without a tried_at", %{
      user: user
    } do
      now = NaiveDateTime.utc_now()
      ten_minutes_from_now = NaiveDateTime.add(now, 10, :minute)

      card =
        Factory.card_factory(user)

      loaded_card =
        Red.Practice.load!(card, :interval)

      assert nil == loaded_card.interval
    end
  end
end
