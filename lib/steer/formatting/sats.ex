defmodule Steer.Formatting.Sats do
  def to_human(amount) do
    "#{Number.SI.number_to_si(amount / 1000, unit: "", precision: 0)}"
  end
end
