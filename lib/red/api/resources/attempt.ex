defmodule Red.Api.Attempt do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  alias Red.Words

  actions do
    defaults [:create, :read, :update]

    create :try do
      accept [:tried_spelling, :correct_spelling, :user_id]
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :tried_spelling, :string, allow_nil?: false

    attribute :correct_spelling, :string do
      allow_nil? false
      constraints match: ~r/#{Words.words() |> Enum.join("|")}/
    end

    create_timestamp :created_at
  end

  relationships do
    belongs_to :user, Red.Accounts.User,
      attribute_writable?: true,
      allow_nil?: false
  end

  postgres do
    table "attempts"
    repo Red.Repo
  end
end
