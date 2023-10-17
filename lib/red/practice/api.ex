defmodule Red.Practice do
  use Ash.Api

  resources do
    resource Red.Practice.Attempt
    resource Red.Practice.Card
  end
end
