defmodule SteerWeb.Components.LiquidityMeeter do
  use Phoenix.Component

  def liquidity_meeter(assigns) do
    ~H"""
    <div class="liquidity-meeter">
      <div class="liquidity-meeter-value" style={"width: #{assigns.balance}%;"}></div>
    </div>
    """
  end
end
