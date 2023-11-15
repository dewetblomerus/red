defmodule RedWeb.PageController do
  use RedWeb, :controller

  def about(conn, _params) do
    render(conn, :about)
  end

  def privacy(conn, _params) do
    render(conn, :privacy)
  end
end
