defmodule Red.Api.Registry do
  use Ash.Registry

  entries do
    entry Red.Api.User
    entry Red.Api.Attempt
  end
end
