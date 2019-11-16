defmodule TwitterClasses.Core do
  def start_link(id) do
    GenServer.start_link(__MODULE__, [id])
  end

  def init(init_args) do
    {:ok, id} = Enum.fetch(init_args, 0)
    node_state = %{"id" => id, "handle" => nil}
    {:ok, node_state}
  end
end
