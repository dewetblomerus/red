defmodule Red.Accounts.UserIdentity do
  use Ash.Resource,
    domain: Red.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.UserIdentity]

  user_identity do
    user_resource Red.Accounts.User
  end

  postgres do
    table "user_identities"
    repo Red.Repo
  end
end
