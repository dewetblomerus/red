import Config

config :red,
  auth0: [
    client_id: "auth0-client-id",
    redirect_url: "http://localhost:4000/auth/auth0/callback",
    client_secret: "auth0-client-secret",
    site: "auth0-domain"
  ]
