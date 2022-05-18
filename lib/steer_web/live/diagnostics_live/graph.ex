# defmodule SteerWeb.DiagnosticsLive.Graph do
#   use Phoenix.Component

#   alias Steer.GraphRepo

#   def graph(assigns) do
#     node_count = GraphRepo.get_number_of_nodes()

#     ~H"""
#     <div class="diagnostics-graph-info">
#       <%= node_count %> nodes
#     </div>

#     <div class="diagnostics-graph-status">
#       Graph status: <em><%= assigns.status %></em>
#     </div>

#     <button phx-click="refresh_graph">
#       refresh
#     </button>
#     """
#   end
# end
