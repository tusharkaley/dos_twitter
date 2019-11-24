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

<<<<<<< HEAD

  def tweet (tweet, pid) do
    GenServer.cast(pid, {:tweet, message })
  end

  def handle_cast({:tweet, message}, node_state) do


  end


=======
  def tweet_retweet(pid) do
    GenServer.cast(pid,{:tweet_retweet})
  end

  def get_my_notifications(pid) do
    GenServer.cast(pid, {:get_my_notifications})
  end

  def receive_notifications(pid, notif_data) do
    GenServer.cast(pid, {:receive_notifications, notif_data})
  end
@doc """
Server side function to get_my_notifs
"""
  def handle_cast({:get_my_notifications}, node_state) do
    IO.inspect(node_state)
  end
@doc """
Server side function to receive notifs
"""
  def handle_cast({:receive_notifications, notif_data}, node_state) do
    IO.inspect(notif_data)
    IO.inspect(node_state)
  end
  def handle_cast({:tweet_retweet}, node_state) do
    my_handle = node_state["handle"]
      if TwitterClasses.Utils.toss_coin() == 1 do
        tweet_data = TwitterClasses.Utils.generate_tweet(my_handle)
        tweet_data_map = %{}

        tweet_data_map = Map.put(tweet_data_map, "tweet_txt", elem(tweet_data, 0))
        tweet_data_map = Map.put(tweet_data_map, "hashtags", elem(tweet_data, 1))
        tweet_data_map = Map.put(tweet_data_map, "mentions", elem(tweet_data, 2))
        tweet_data_map = Map.put(tweet_data_map, "tweet_hash", elem(tweet_data, 3))
        tweet_data_map = Map.put(tweet_data_map, "new_tweet", true)
        IO.inspect(tweet_data_map)
        # TODO: Send tweet_data_map to the tracker from here
      else
        # coin toss -> heads(0) RETWEET
        # Pick out a tweet you want the user tp retweet
        tweet_data_map = %{}
        {tweet_hash, tweet_text} = TwitterClasses.Utils.get_random_tweet()
        tweet_data_map = Map.put(tweet_data_map, "tweet_txt", tweet_text)
        tweet_data_map = Map.put(tweet_data_map, "tweet_hash", tweet_hash)
        tweet_data_map = Map.put(tweet_data_map, "new_tweet", false)
        IO.inspect(tweet_data_map)
        # TODO: Send tweet_data_map to the tracker from here


      end
  end
>>>>>>> af39dba98beb05c8ab5f46cba8981e807f319155
end
