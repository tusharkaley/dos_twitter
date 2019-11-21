defmodule TwitterClasses.Core do
  def start_link(id, handle) do
    GenServer.start_link(__MODULE__, [id, handle])
  end

  def init(init_args) do
    {:ok, id} = Enum.fetch(init_args, 0)
    {:ok, handle} = Enum.fetch(init_args, 1)
    node_state = %{"id" => id, "handle" => handle}
    {:ok, node_state}
  end


  def tweet (tweet, pid) do
    GenServer.cast(pid, {:tweet, message })
  end

  def handle_cast({:tweet, message}, node_state) do


  end


end
