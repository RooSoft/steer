defmodule SteerWeb.Live.HomeTest do
  use SteerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Steer.Factory

  test "home contains one channel", %{conn: conn} do
    insert(:channel)

    {:ok, view, html} = live(conn, "/")

    assert html =~ "Steer"
    assert view |> channel_count(1) |> has_element?
  end

  defp channel_count(view, count) do
    element(view, "span.home-live-channel-number", Integer.to_string(count))
  end
end
