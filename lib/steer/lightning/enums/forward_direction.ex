defmodule Steer.Lightning.Enums.ForwardDirection do
  use EctoEnum,
    type: :forward_direction,
    enums: [:in, :out]
end
