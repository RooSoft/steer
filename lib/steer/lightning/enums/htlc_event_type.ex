defmodule Steer.Lightning.Enums.HtlcEventType do
  use EctoEnum,
    type: :htlc_event_type,
    enums: [:forward, :forward_fail, :settle, :link_fail]
end
