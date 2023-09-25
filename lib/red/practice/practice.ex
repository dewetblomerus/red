defmodule Red.Practice do
  use Ash.Api

  resources do
    # This defines the set of resources that can be used with this API
    registry Red.Practice.Registry
  end
end

# Red.Practice.Word
# |> Ash.Changeset.for_create(:populate, %{word: "the"})
# |> Red.Practice.create!()
