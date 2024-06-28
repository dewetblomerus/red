defmodule Red.Accounts do
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  admin do
    show?(true)
  end

  resources do
    resource Red.Accounts.User
    resource Red.Practice.Card
  end
end
