defmodule SteerWeb.DiagnosticsLive.Liquidity do
  use Phoenix.Component

  def liquidity(assigns) do
    assigns =
      assigns
      |> assign_formatted_local_balance()
      |> assign_formatted_remote_balance()

    ~H"""
    <div>
      Local balance: <%= @local_balance %> sats
    </div>
    <div>
      Remote balance: <%= @remote_balance %> sats
    </div>
    """
  end

  defp assign_formatted_local_balance(assigns) do
    formatted =
      assigns
      |> get_local_balance()
      |> format_balance

    assigns
    |> assign(:local_balance, formatted)
  end

  defp assign_formatted_remote_balance(assigns) do
    formatted =
      assigns
      |> get_remote_balance()
      |> format_balance

    assigns
    |> assign(:remote_balance, formatted)
  end

  defp get_local_balance(assigns) do
    assigns.channels
    |> Enum.reduce(0, fn channel, funds ->
      funds + channel.local_balance
    end)
  end

  defp get_remote_balance(assigns) do
    assigns.channels
    |> Enum.reduce(0, fn channel, funds ->
      funds + channel.remote_balance
    end)
  end

  defp format_balance(balance) do
    Number.SI.number_to_si(balance / 1000, unit: "", precision: 1)
  end
end
