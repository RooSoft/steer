defmodule Steer.Lightning.ForwardDirection do
  use EctoEnum,
    type: :forward_direction,
    enums: [:in, :out]
end
