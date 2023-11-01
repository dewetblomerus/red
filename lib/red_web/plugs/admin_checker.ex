defmodule RedWeb.AdminChecker do
  def call(conn, opts) do
    dbg("call called")
    dbg(conn)
    check_super_user(conn, opts)
  end

  def init(opts) do
    dbg("init called")
    opts
  end

  def call(conn, opts \\ []) do
    check_super_user(conn, opts)
  end

  defp check_super_user(conn, _opts) do
    current_user =
      conn.assigns.current_user

    email = current_user.email |> Ash.CiString.value()

    case email do
      "dewetblomerus@gmail.com" -> conn
      _ -> halt_plug(conn)
    end
  end

  defp halt_plug(conn) do
    conn
    |> Plug.Conn.put_status(:unauthorized)
    |> Plug.Conn.halt()
  end
end
