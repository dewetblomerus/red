defmodule Red.Practice.CardTest do
  use Red.DataCase, async: true
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

  describe "try/1" do
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
end
