defmodule RedWeb.AdminChecker do
  def call(conn, opts) do
    check_super_user(conn, opts)
  end

  def init(opts) do
    opts
  end

  def call(conn, opts \\ []) do
    check_super_user(conn, opts)
  end

  defp check_super_user(conn, _opts) do
    current_user =
      conn.assigns.current_user

    email = current_user.email |> Ash.CiString.value()

    if email == "dewetblomerus@gmail.com" && current_user.email_verified do
      conn
    else
      redirect_and_halt(conn)
    end
  end

  defp redirect_and_halt(conn) do
    conn
    |> Phoenix.Controller.redirect(to: "/")
    |> Plug.Conn.halt()
  end
end
