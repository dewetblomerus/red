defmodule Red.Api do
  use Ash.Api

  resources do
    resource Red.Api.User
    registry Red.Api.Registry
  end
end
