defmodule Red.Accounts do
  use Ash.Api,
    extensions: [AshAdmin.Api]

  admin do
    show?(true)
  end

  resources do
    resource Red.Accounts.User
    resource Red.Practice.Card
  end
end
