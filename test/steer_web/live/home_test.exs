defmodule SteerWeb.Live.HomeTest do
  use SteerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Steer"
  end
end
