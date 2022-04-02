defmodule SteerWeb.DiagnosticsLive.Liquidity do
  use Phoenix.Component

  def liquidity(assigns) do
    local_balance =
      assigns.channels
      |> Enum.reduce(0, fn channel, funds ->
        funds + channel.local_balance
      end)

    remote_balance =
      assigns.channels
      |> Enum.reduce(0, fn channel, funds ->
        funds + channel.remote_balance
      end)

    ~H"""
    <div>
      Local balance: <%= Number.SI.number_to_si(local_balance/1000, unit: "", precision: 1) %> sats
    </div>
    <div>
      Remote balance: <%= Number.SI.number_to_si(remote_balance/1000, unit: "", precision: 1) %> sats
    </div>
    """
  end
end
