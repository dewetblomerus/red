defmodule Red.Accounts do
  use Ash.Api

  resources do
    resource Red.Accounts.User
  end
end
