defmodule SteerWeb.Live.HomeTest do
  use SteerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "GET /", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Steer"
    assert view |> element("span.home-live-channel-number", "0") |> has_element?
    assert view |> element("div[data-phx-component=1]") |> has_element?
    assert view |> element("p.alert-info") |> has_element?
    assert view |> element("div.home-live-channel-count") |> has_element?
  end
end
