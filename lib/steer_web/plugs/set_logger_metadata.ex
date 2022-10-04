defmodule SteerWeb.Plugs.SetLoggerMetadata do
  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> set_remote_ip()
  end

  defp set_remote_ip(conn) do
    ip = get_ip(conn)

    Logger.metadata(remote_ip: ip)

    conn
  end

  defp get_ip(conn) do
    case Plug.Conn.get_req_header(conn, "x-forwarded-for") do
      [] -> format_ip(conn)
      ip_list -> List.last(ip_list)
    end
  end

  defp format_ip(%{remote_ip: remote_ip}) do
    :inet_parse.ntoa(remote_ip)
    |> to_string
  end
end
