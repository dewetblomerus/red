defmodule Red.Practice.Card do
  alias Red.Practice.Card

  require Logger

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  code_interface do
    define_for Red.Practice

    define :create, action: :create
    define :for_user, action: :for_user
    define :get_by, action: :get_by
    define :lookahead, action: :lookahead
    define :next, action: :next
    define :oldest_untried_card, action: :oldest_untried_card
  end

  actions do
    defaults [:read, :update]

    read :for_user do
      filter expr(user_id == ^actor(:id))
    end

    create :create do
      change relate_actor(:user)
    end

    read :next do
      get? true

      prepare build(limit: 1, sort: [retry_at: :asc])

      filter expr(user_id == ^actor(:id) and retry_at <= now())

      prepare fn query, context ->
        Ash.Query.after_action(query, fn
          _, [] ->
            Logger.debug("No cards due 📭")

            reviewed_today_count =
              Red.Accounts.load!(
                context.actor,
                [:count_cards_reviewed_today]
              ).count_cards_reviewed_today

            if reviewed_today_count < context.actor.daily_goal do
              Logger.debug("Grabbing a new card ✨")
              Card.oldest_untried_card(actor: context.actor)
            else
              Logger.debug("Looking Ahead 🔭")
              Card.lookahead(actor: context.actor)
            end

          _, results ->
            Logger.debug("A card was found with retry_at <= now ✅")
            {:ok, results}
        end)
      end
    end

    read :lookahead do
      prepare build(limit: 1, sort: [retry_at: :asc])

      filter expr(user_id == ^actor(:id) and retry_at <= from_now(20, :minute))
    end

    read :oldest_untried_card do
      prepare build(limit: 1, sort: [created_at: :asc])

      filter expr(is_nil(retry_at) and user_id == ^actor(:id))
    end

    read :get_by do
      filter expr(user_id == ^actor(:id))
      get_by [:word]
    end

    update :try do
      accept [:tried_spelling]
      argument(:tried_spelling, :string, allow_nil?: false)
      manual Red.Practice.Card.Try
    end
  end

  calculations do
    calculate :interval_in_seconds,
              :integer,
              expr(fragment("EXTRACT(EPOCH FROM ?)", retry_at - tried_at))
  end

  attributes do
    integer_primary_key :id

    attribute :correct_streak, :integer, allow_nil?: false, default: 0
    attribute :phrase, :string, allow_nil?: false
    attribute :retry_at, :utc_datetime, allow_nil?: true
    attribute :tried_at, :utc_datetime, allow_nil?: true
    attribute :word, :string, allow_nil?: false

    create_timestamp :created_at
    create_timestamp :updated_at
  end

  identities do
    identity :unique_word, [:word, :user_id]
  end

  relationships do
    belongs_to :user, Red.Accounts.User,
      attribute_writable?: true,
      attribute_type: :integer,
      allow_nil?: false
  end

  postgres do
    table "cards"
    repo Red.Repo
  end
end
