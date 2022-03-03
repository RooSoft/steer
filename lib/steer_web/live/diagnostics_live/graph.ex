defmodule SteerWeb.DiagnosticsLive.Graph do
  use Phoenix.Component

  alias Steer.GraphRepo

  def graph(assigns) do
    node_count = GraphRepo.get_number_of_nodes()

    ~H"""
    <div class="diagnostics-graph-info">
      <%= node_count %> nodes
    </div>

    <button>
      refresh
    </button>
    """
  end
end
