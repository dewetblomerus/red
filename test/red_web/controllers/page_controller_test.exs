defmodule RedWeb.PageControllerTest do
  use RedWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 302) =~ "You are being"
  end
end
