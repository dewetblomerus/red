defmodule RedWeb.PageController do
  use RedWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.

    conn
    |> assign(:current_user, conn.assigns.current_user)
    |> render(:home)
  end

  def about(conn, _params) do
    render(conn, :about)
  end

  def privacy(conn, _params) do
    render(conn, :privacy)
  end
end
