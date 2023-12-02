defmodule Red.Words do
  def lists do
    :persistent_term.get({__MODULE__, :wordlists})
  end
end
