defmodule TwitterClasses.Utils do
  require Logger
  	@doc """
		Function to get the child Spec for the workers
	"""
	def add_children(child_class, num_nodes, script_pid) do
    {:ok, agg} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => :tracker, :start => {TwitterClasses.Tracker, :start_link, [num_nodes, script_pid]}, :restart => :transient,:type => :worker})
    Logger.debug("Added Tracker on #{inspect agg}")
    Enum.each 1..num_nodes, fn x ->
      {:ok, _child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => x, :start => {child_class, :start_link, [x]}, :restart => :transient,:type => :worker})
    end
    Logger.debug("Added children and tracker")
  end

  @spec get_guid(any) :: any
  def get_guid(pid) do
    [head| _tail] = :ets.lookup(:pid_id_mapping, "pid_to_id")
    pid_to_id = elem(head, 1)
    guid = Map.get(pid_to_id, pid)
    guid
  end

  def get_pid(guid) do
    [head| _tail] = :ets.lookup(:id_pid_mapping, "id_to_pid")
    id_to_pid = elem(head, 1)
    pid = Map.get(id_to_pid, guid)
    pid
  end

  def set_id_pid_table(id_to_pid, pid_to_id) do
    :ets.new(:id_pid_mapping, [:named_table, read_concurrency: true])
    :ets.insert(:id_pid_mapping, {"id_to_pid", id_to_pid})

    :ets.new(:pid_id_mapping, [:named_table, read_concurrency: true])
    :ets.insert(:pid_id_mapping, {"pid_to_id", pid_to_id})

    tweets_store = %{"username" => "tweet"}
    
    :ets.new(:tweets_store, [:named_table, read_concurrency: true])
    :ets.insert(:tweets_store, {"tweets_store", pid_to_id})

  end

  def set_subscribers(username) do
    subscribers = %{"username" => "subscribersList"}
    :ets.new(:subscribers_list,[:named_table,read_concurrency: true])
    :ets.insert(:subscribers_list, subscribers)
  end
end
