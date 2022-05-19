defmodule SteerWeb.Live.HomeTest do
  use SteerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "GET /", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Steer"
  end
end
