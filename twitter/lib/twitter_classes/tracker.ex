defmodule TwitterClasses.Tracker do
  use GenServer
  require Logger

  def start_link(num_nodes, script_pid) do
    GenServer.start_link(__MODULE__, [num_nodes, script_pid], [name: :tracker])
  end
  @doc """
    Client side function to log the number of logs required to reach the destination
    and check if it is the max
  """
  def collect_hops(source) do
    GenServer.cast(:aggregator, {:tweets_done, source})
  end

@doc """
  Init function to set the state of the genserver
"""
  def init(init_args) do
    {:ok, total_nodes} = Enum.fetch(init_args, 0)
    {:ok, script_pid} = Enum.fetch(init_args, 1)
    node_state = %{"num_nodes_done" => 0, "total_nodes" => total_nodes, "terminate_addr"=> script_pid}
    {:ok, node_state}
  end
@doc """
  Server side function to log hops
"""
  def handle_cast({:tweets_done, _source}, node_state) do

    node_state = Map.put(node_state, "num_nodes_done", node_state["num_nodes_done"] + 1)
    num_nodes_done = node_state["num_nodes_done"]
    if num_nodes_done == node_state["total_nodes"] do
      # Time to terminate
      send(node_state["terminate_addr"], {:terminate_now, self()})
    end
    # IO.inspect(node_state)
    {:noreply, node_state}
  end

end
