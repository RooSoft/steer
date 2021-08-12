defmodule Steer.Lightning.Enums.ChannelStatus do
  use EctoEnum,
    type: :channel_status,
    enums: [:active, :inactive, :closed]
end
