defmodule TwitterClasses.Utils do
  require Logger
  	@doc """
		Function to get the child Spec for the workers
	"""
  def add_core_users(child_class, num_nodes, script_pid) do
    :ets.new(:users, [:named_table, read_concurrency: true])
    {:ok, agg} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => :tracker, :start => {TwitterClasses.Tracker, :start_link, [num_nodes, script_pid]}, :restart => :transient,:type => :worker})
    Logger.debug("Added Tracker on #{inspect agg}")
    Enum.each 1..num_nodes, fn x ->
      handle = get_random_handle()
      {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => x, :start => {child_class, :start_link, [x, handle]}, :restart => :transient,:type => :worker})
      add_user(handle, x, child)
      Logger.debug("User added to table #{inspect :ets.lookup(:users, handle)}")
    end
    Logger.debug("Added children and tracker")
  end

  def register_core_users do
    # What data would a user have
    # Twitter handle
    :tushar
  end

  def get_random_handle() do
    len = Enum.random(5..20)
    :crypto.strong_rand_bytes(len) |> Base.url_encode64 |> binary_part(0, len)
  end
  def add_user(handle, id, pid) do
    # Storing users in a table in
    :ets.insert(:users, {handle, true, id, pid})
    IO.inspect(:ets.tab2list(:users))
  end

  def delete_user(handle) do
    :ets.delete(:users, handle)
    :ets.insert(:users, {handle, false})
  end

end
