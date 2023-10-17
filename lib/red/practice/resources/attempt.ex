defmodule Red.Practice.Attempt do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  alias Red.Words

  actions do
    defaults [:create, :read, :update]
  end

  code_interface do
    define_for Red.Practice
    define :create, action: :create
    define :read_all, action: :read
    define :update, action: :update
  end

  changes do
    change relate_actor(:user)
  end

  attributes do
    integer_primary_key :id
    attribute :tried_spelling, :string, allow_nil?: false

    attribute :correct_spelling, :string do
      allow_nil? false
      constraints match: ~r/#{Words.words() |> Enum.join("|")}/
    end

    create_timestamp :created_at
  end

  relationships do
    belongs_to :user, Red.Accounts.User,
      attribute_type: :integer,
      allow_nil?: false
  end

  postgres do
    table "attempts"
    repo Red.Repo
  end
end
