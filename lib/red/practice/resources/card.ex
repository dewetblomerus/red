defmodule Red.Practice.Card do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:create, :read, :update]
  end

  code_interface do
    define_for Red.Practice

    define :create, action: :create
  end

  changes do
    change relate_actor(:user)
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
