defmodule Red.Practice.Card do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  code_interface do
    define_for Red.Practice

    define :create, action: :create

    define :next, action: :next
    define :oldest_untried_card, action: :oldest_untried_card
  end

  actions do
    defaults [:read, :update]

    create :create do
      change relate_actor(:user)
    end

    read :next do
      get? true

      prepare build(limit: 1, sort: [retry_at: :asc])

      filter expr(user_id == ^actor(:id) and retry_at <= now())

      prepare fn query, context ->
        Ash.Query.after_action(query, fn
          query, [] ->
            dbg("No cards found with retry_at < now")
            Red.Practice.Card.oldest_untried_card(actor: context.actor)

          _query, results ->
            dbg("A card was found with retry_at < now")
            {:ok, results}
        end)
      end
    end

    read :oldest_untried_card do
      prepare build(limit: 1, sort: [created_at: :asc])

      filter expr(is_nil(retry_at) and user_id == ^actor(:id))
    end

    update :try do
      accept [:tried_spelling]
      argument(:tried_spelling, :string, allow_nil?: false)
      manual Red.Practice.Card.Try
    end
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
