defmodule Red.Api do
  use Ash.Api

  resources do
    resource Red.Api.Attempt
  end
end
