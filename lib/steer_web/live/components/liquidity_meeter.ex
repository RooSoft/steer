defmodule SteerWeb.Components.LiquidityMeeter do
  use Phoenix.Component

  def liquidity_meeter(assigns) do
    ~H"""
    <div class="liquidity-meeter">
      <div class={get_class(assigns.status)} style={"width: #{assigns.balance}%;"}></div>
    </div>
    """
  end

  def get_class(:active) do
    "liquidity-meeter-value liquidity-meeter-active"
  end

  def get_class(_) do
    "liquidity-meeter-value liquidity-meeter-inactive"
  end
end
