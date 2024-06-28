defmodule Red.Practice do
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  admin do
    show?(true)
  end

  resources do
    resource Red.Practice.Card
    resource Red.Accounts.User
  end
end
