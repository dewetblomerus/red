defmodule Red.Practice.Card do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  code_interface do
    define_for Red.Practice

    define :create, action: :create

    define :next, action: :next, args: [:user_id]
    define :next_retry_at, action: :next_retry_at, args: [:user_id]
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

      prepare build(limit: 1, sort: [created_at: :asc])

      filter expr(is_nil(retry_at) and user_id == ^arg(:user_id))

      prepare fn query, _ ->
        Ash.Query.after_action(query, fn
          query, [] ->
            dbg("no cards with retry_at: nil")

            {:ok, results} = Red.Practice.Card.next_retry_at(query.arguments.user_id)
            {:ok, results}

          _query, results ->
            dbg("found a card with retry_at: nil")
            {:ok, results}
        end)
      end
    end

    read :next_retry_at do
      argument :user_id, :integer do
        allow_nil? false
      end

      prepare build(limit: 1, sort: [retry_at: :asc])

      filter expr(retry_at < now())
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
