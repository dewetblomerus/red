defmodule Red.Practice.Word do
  # This turns this module into a resource
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  actions do
    # Add a set of simple actions. You'll customize these later.
    defaults [:create, :read, :update, :destroy]

    create :populate do
      # By default you can provide all public attributes to an action
      # This action should only accept the word
      accept [:word]
    end
  end

  # Attributes are the simple pieces of data that exist on your resource
  attributes do
    # Add a string type attribute called `:spelling`
    attribute :word, :string do
      allow_nil? false
      primary_key? true
    end
  end

  postgres do
    table "words"
    repo Red.Repo
  end
end
