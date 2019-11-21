defmodule TwitterClasses.Simulator do
  require Logger
    def start_link(action_id) do
      GenServer.start_link(__MODULE__, [action_id], [name: :simulator])
    end

    def init(init_arg) do
      {:ok, act_id} = Enum.fetch(init_arg, 0)
      node_state = %{"action_id" => act_id, "num_users"=>0}
      {:ok, node_state}
    end

    def register_user(name, id, pid) do
      GenServer.cast(:simulator, {:register_user, name, id, pid})
    end

    def delete_user(name , id, pid) do
      GenServer.cast(:simulator, {:delete_user, name, id, pid})

    end


    def handle_cast({:register_user, name, id, pid}, node_state) do
      [head| _tail] = :ets.lookup(:id_pid_mapping, "id_to_pid")
      id_to_pid = elem(head, 1)
      id_to_pid= Map.put id_to_pid, id, pid
      num_users = node_state["num_users"] + 1
      node_state = Map.put(node_state, "num_users", num_users)
    end

    def handle_cast({:delete_user, name, id, pid}, node_state) do
      [head| _tail] = :ets.lookup(:id_pid_mapping, "id_to_pid")
      #REMOVE THE USER MAPPING?
      id_to_pid = elem(head, 1)
      id_to_pid= Map.delete id_to_pid, id
      num_users = node_state["num_users"] - 1
      node_state = Map.put(node_state, "num_users", num_users)
    end

    def schedule() do
      Process.send_after(self(), :bump, 300)

    end

    def handle_info(:bump) do
      # This function will periodically 
      schedule()

    end

  end
