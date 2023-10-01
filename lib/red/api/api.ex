defmodule Red.Api do
  use Ash.Api

  resources do
    resource Red.Api.Attempt
    resource Red.Api.User
  end
end
