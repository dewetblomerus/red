defmodule Red.Practice do
  use Ash.Api,
    extensions: [AshAdmin.Api]

  admin do
    show?(true)
  end

  resources do
    resource Red.Practice.Card
  end
end
