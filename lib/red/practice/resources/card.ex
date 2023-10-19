defmodule Red.Practice.Card do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  code_interface do
    define_for Red.Practice

    define :create, action: :create

    define :next, action: :next, args: [:user_id]
    define :oldest_untried_card, action: :oldest_untried_card, args: [:user_id]
  end

  actions do
    defaults [:read, :update]

    create :create do
      change relate_actor(:user)
    end

    read :next do
      argument :user_id, :integer do
        allow_nil? false
      end

      get? true

      prepare build(limit: 1, sort: [retry_at: :asc])

      filter expr(retry_at < now() and user_id == ^arg(:user_id))

      prepare fn query, _ ->
        Ash.Query.after_action(query, fn
          query, [] ->
            dbg("found no cards with retry_at < now")
            Red.Practice.Card.oldest_untried_card(query.arguments.user_id)

          _query, results ->
            dbg("found a card with retry_at < now")
            {:ok, results}
        end)
      end
    end

    read :oldest_untried_card do
      argument :user_id, :integer do
        allow_nil? false
      end

      prepare build(limit: 1, sort: [created_at: :asc])

      filter expr(is_nil(retry_at) and user_id == ^arg(:user_id))
    end
  end

  attributes do
    integer_primary_key :id

    attribute :word, :string, allow_nil?: false
    attribute :tried_at, :utc_datetime, allow_nil?: true
    attribute :retry_at, :utc_datetime, allow_nil?: true
    attribute :correct_streak, :integer, allow_nil?: false, default: 0

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
