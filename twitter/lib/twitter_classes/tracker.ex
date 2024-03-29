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
  def tweets_done(source) do
    GenServer.cast(:tracker, {:tweets_done, source})
  end

  def get_notifications(sender) do
    GenServer.cast(:tracker, {:get_notifications, sender})
  end

  def notify_users(user_pid,tweet) do
    GenServer.cast(:tracker, {:notify_users, user_pid, tweet})
  end

  def query_hashtag(hashtag) do
    GenServer.call(:tracker, {:query_hashtag, hashtag})
  end

  def query_mention(handle) do
    GenServer.call(:tracker, {:query_mention, handle})
  end
@doc """
  Init function to set the state of the genserver
"""
  def init(init_args) do
    {:ok, total_nodes} = Enum.fetch(init_args, 0)
    {:ok, script_pid} = Enum.fetch(init_args, 1)
    node_state = %{"num_nodes_done" => 0, "total_nodes" => total_nodes, "terminate_addr"=> script_pid, "num_tweets" => 0, "num_retweets"=>0, "num_mentions"  => 0, "num_hashtags"=>0}
    {:ok, node_state}
  end

@doc """
  Server side function to log hops
"""
  def handle_cast({:tweets_done, _source}, node_state) do

    node_state = Map.put(node_state, "num_nodes_done", node_state["num_nodes_done"] + 1)
    num_nodes_done = node_state["num_nodes_done"]
    if num_nodes_done == 1 do
      Logger.debug("#{num_nodes_done} user done sending requested number of messages")
    else
      Logger.debug("#{num_nodes_done} users done sending requested number of messages")
    end

    if num_nodes_done == node_state["total_nodes"] do
      # Time to terminate
      send(node_state["terminate_addr"], {:terminate_now, self()})
    end
    # IO.inspect(node_state)
    {:noreply, node_state}
  end

  def handle_cast({:get_notifications, sender}, node_state) do
    _user_handle = TwitterClasses.DBUtils.get_from_table(:users, sender)
    {:noreply, node_state}
  end

	@doc """
	Server side function to disctribute tweets to followers
	"""
	def handle_cast({:notify_users,source,tweet},node_state) do
    followers_map = TwitterClasses.DBUtils.get_from_table(:user_followers, "user_followers")
    followers_map = elem(followers_map, 1)
    followers = Map.get followers_map, source
    tweet_hash = Map.get(tweet, "tweet_hash")
    t_or_rt = Map.get(tweet, "new_tweet")

    node_state = if  t_or_rt == true do
      Map.put(node_state, "num_tweets", node_state["num_tweets"]+1)
    else
      Map.put(node_state, "num_retweets", node_state["num_retweets"]+1)
    end
    # notify followers
    Enum.each followers, fn(user) ->
      values = TwitterClasses.DBUtils.get_from_table(:users, user)
      if(elem(values, 1) == true and elem(values, 2) == true) do
        # If the user is registered and is connected
        tweet_type = if Map.get(tweet, "new_tweet") do
          :new_tweet
        else
          :retweet
        end
        TwitterClasses.Core.receive_notifications(user, {Map.get(tweet, "tweet_txt"), tweet_type})
      else
        # the user is either not registered or not connected or both

        # values = TwitterClasses.DBUtils.get_from_table(:user_notifications, user)
        # notifications = elem(values,2)
        # notifications = notifications ++ [tweet_hash]
        TwitterClasses.DBUtils.add_or_update(:user_notifications, user, {tweet_hash,source})
      end
      TwitterClasses.DBUtils.add_or_update(:user_wall, user, {tweet_hash,source})

    end

    # If its a new tweet and it has mentions then notify the users

    if Map.get(tweet, "new_tweet") do
      mentions = Map.get(tweet, "mentions")
      handle_to_pid = TwitterClasses.DBUtils.get_from_table(:aux_info, :handle_to_pid)
      handle_to_pid = elem(handle_to_pid, 1)
      Enum.each(mentions, fn x ->
        pid = Map.get(handle_to_pid, x)
        values = TwitterClasses.DBUtils.get_from_table(:users, pid)
        if(elem(values, 1) == true and elem(values, 2) == true) do
          # If the user is registered and is connected

          TwitterClasses.Core.receive_notifications(pid, {Map.get(tweet, "tweet_txt"), :mention})
        else
          # the user is either not registered or not connected or both

          # values = TwitterClasses.DBUtils.get_from_table(:user_notifications, user)
          # notifications = elem(values,2)
          # notifications = notifications ++ [tweet_hash]
          TwitterClasses.DBUtils.add_or_update(:user_notifications, pid, {tweet_hash,source})
        end
      end)
    else
      node_state
    end
    node_state = if Map.get(tweet, "new_tweet") do
      mentions = Map.get(tweet, "mentions")
      hashtags = Map.get(tweet, "hashtags")
      ns = Map.put(node_state, "num_mentions", node_state["num_mentions"]+length(mentions))
      ns = Map.put(ns, "num_hashtags", node_state["num_hashtags"]+length(hashtags))
      ns
    else
      node_state
    end
    {:noreply, node_state}
	end
  @doc """
  Server side function to query a hashtag
  """
  def handle_call({:query_hashtag,hashtag},_from, node_state) do
    tweets = TwitterClasses.Utils.query_hashtag(hashtag)
    {:reply, tweets, node_state}
  end

  @doc """
Server side function to query a mention
"""
def handle_call({:query_mention, my_handle},_from, node_state) do
  tweets = TwitterClasses.Utils.query_mentions(my_handle)
  {:reply, tweets, node_state}
end
  @doc """
  Server side function to query a hashtag
  """
  def handle_call(:get_stats,_from, node_state) do
    {:reply, node_state, node_state}
  end

end
