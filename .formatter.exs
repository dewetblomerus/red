[
  import_deps: [
    :ash_authentication_phoenix,
    :ash_authentication,
    :ash_postgres,
    :ash,
    :ecto_sql,
    :ecto,
    :phoenix
  ],
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]
