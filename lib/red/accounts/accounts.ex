defmodule Red.Accounts do
  use Ash.Api

  resources do
    resource Red.Accounts.User
    resource Red.Accounts.Token
  end
end
