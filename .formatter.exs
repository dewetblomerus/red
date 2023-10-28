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
  line_length: 80,
  subdirectories: ["priv/*/migrations"],
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{heex,ex,exs}",
    "{config,lib,test}/**/*.{heex,ex,exs}",
    "priv/*/seeds.exs"
  ]
]
