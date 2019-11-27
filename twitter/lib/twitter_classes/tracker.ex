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
    GenServer.cast(:tracker, {:tweets_done, source})
  end

  def get_notifications(sender) do
    GenServer.cast(:tracker, {:get_notifications, sender})
  end

  def notify_followers(user_pid,tweet) do
    GenServer.cast(:tracker, {:notify_followers, user_pid, tweet})
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
  def handle_cast({:get_notifications, sender}, node_state) do
    user_handle = TwitterClasses.DBUtils.get_from_table(:users, sender)
    {:noreply, node_state}
  end

	@doc """
	Server side function to disctribute tweets to followers
	"""
	def handle_cast({:notify_followers,source,tweet},node_state) do
		followers_map = TwitterClasses.DBUtils.get_from_table(:user_followers, "user_followers")
    followers = Map.get followers_map, source
    tweet_hash = TwitterClasses.Utils.get_tweet_hash(tweet)
    Enum.each followers, fn(user) ->
      values = TwitterClasses.DBUtils.get_from_table(:users, user)
      if(elem(values, 1) == true and elem(values, 2) == true) do
        TwitterClasses.Core.receive_notifications(user, tweet)
      else
        # values = TwitterClasses.DBUtils.get_from_table(:user_notifications, user)
        # notifications = elem(values,2)
        # notifications = notifications ++ [tweet_hash]
        TwitterClasses.DBUtils.add_or_update(:user_notifications, user, {tweet_hash,source})
      end
      TwitterClasses.DBUtils.add_or_update(:user_wall, user, {tweet_hash,source})
			
    end
    {:noreply, node_state}
	end

end
