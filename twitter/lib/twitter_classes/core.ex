defmodule TwitterClasses.Core do
  def start_link(id, handle, num_tweets) do
    GenServer.start_link(__MODULE__, [id, handle, num_tweets])
  end

  def init(init_args) do
    {:ok, id} = Enum.fetch(init_args, 0)
    {:ok, handle} = Enum.fetch(init_args, 1)
    {:ok, num_tweets} = Enum.fetch(init_args, 2)

    node_state = %{"id" => id, "handle" => handle, "my_tweets" => 0, "tweet_thresh" =>num_tweets}
    {:ok, node_state}
  end

  def tweet(pid) do
    GenServer.cast(pid,{:tweet})
  end

  def retweet(pid) do
    GenServer.cast(pid,{:retweet})
  end

  def get_my_notifications(pid) do
    GenServer.cast(pid, {:get_my_notifications})
  end

  def get_all_tweets(pid) do
    GenServer.cast(pid, {:get_all_tweets})
  end

  def receive_notifications(pid, notif_data) do
    GenServer.cast(pid, {:receive_notifications, notif_data})
  end

  def follow_user(pid, follow_handle) do
    GenServer.cast(pid, {:follow_user, follow_handle})
  end

@doc """
Server side function to get_my_notifs
"""
  def handle_cast({:get_my_notifications}, node_state) do
    values = TwitterClasses.DBUtils.get_from_table(:user_notifications, self())
    # TwitterClasses.DBUtils.add_to_table(:user_notifications,self(), [])
    IO.inspect values
    {:noreply, node_state}
  end
@doc """
Server side function to receive notifs
"""
  def handle_cast({:receive_notifications, notif_data}, node_state) do
    IO.inspect(notif_data)
    IO.inspect(node_state)
    {:noreply, node_state}
  end

@doc """
Server side function to receive all tweets
"""
def handle_cast({:get_all_tweets}, node_state) do
  values = TwitterClasses.DBUtils.get_from_table(:user_wall, self())
  IO.inspect values
  {:noreply, node_state}
end  

@doc """
Server side function to send tweets
"""
  def handle_cast({:tweet}, node_state) do
    my_handle = node_state["handle"]
      # if TwitterClasses.Utils.toss_coin() == 1 do
        tweet_data = TwitterClasses.Utils.generate_tweet(my_handle)

        tweet_data_map = %{}
        tweet_txt = elem(tweet_data, 0)
        tweet_data_map = Map.put(tweet_data_map, "tweet_txt",tweet_txt)
        tweet_data_map = Map.put(tweet_data_map, "hashtags", elem(tweet_data, 1))
        tweet_data_map = Map.put(tweet_data_map, "mentions", elem(tweet_data, 2))
        tweet_data_map = Map.put(tweet_data_map, "tweet_hash", elem(tweet_data, 3))
        tweet_data_map = Map.put(tweet_data_map, "new_tweet", true)
        TwitterClasses.Tracker.notify_followers(self(), tweet_txt)
        {:noreply, node_state}
        
  end

@doc """
Server side function to send retweets
"""
  def handle_cast({:retweet}, node_state) do
    user_handle = node_state["handle"]
    tweet_data_map = %{}
    {tweet_hash, tweet_text} = TwitterClasses.Utils.get_random_tweet()
    tweet_data_map = Map.put(tweet_data_map, "tweet_txt", tweet_text)
    tweet_data_map = Map.put(tweet_data_map, "tweet_hash", tweet_hash)
    tweet_data_map = Map.put(tweet_data_map, "new_tweet", false)
    TwitterClasses.DBUtils.add_or_update(:user_tweets, user_handle, {tweet_hash,"retweet"})
    TwitterClasses.Tracker.notify_followers(self(), tweet_text)
    {:noreply, node_state}
  end

  def handle_cast({:follow_user,follow_handle},node_state) do
    handle_to_pid = TwitterClasses.DBUtils.get_from_table(:aux_info, :handle_to_pid)
    handle_to_pid = elem(handle_to_pid,1)
    follow_pid  = Map.get handle_to_pid, follow_handle
    TwitterClasses.Utils.follow_user(self(), follow_pid)
    {:noreply, node_state}
  end

end
