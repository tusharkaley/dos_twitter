
try do
  # Check if we have correct arguments

	if length(System.argv) != 2 do
		raise ArgumentError
	end
	# Pick up the arguments
	[num_user, num_msgs] = System.argv
  num_user = elem(Integer.parse(num_user), 0)
  num_msgs = elem(Integer.parse(num_msgs), 0)
  start_time = Time.utc_now()
  # Adding the core users to the supervisor
  pid_to_handle = TwitterClasses.Utils.add_core_users(TwitterClasses.Core, num_user, self(), num_msgs)
  # Get the handle to pid map
  handle_to_pid = Enum.reduce(pid_to_handle, %{}, fn {k, vs}, acc ->
    Map.put(acc,vs,k)
  end)
  handles = Map.values(pid_to_handle)

  # Create the aux_info table
  TwitterClasses.DBUtils.create_table(:aux_info)

  # add handles to the aux_info table
  TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})
  TwitterClasses.DBUtils.add_to_table(:aux_info, {:pid_to_handle, pid_to_handle})
  TwitterClasses.DBUtils.add_to_table(:aux_info, {:handle_to_pid, handle_to_pid})

  # Creating tables
  TwitterClasses.DBUtils.create_table(:tweets)
  TwitterClasses.DBUtils.create_table(:hashtags)
  TwitterClasses.DBUtils.create_table(:mentions)
  TwitterClasses.DBUtils.create_table(:user_tweets)
  TwitterClasses.DBUtils.create_table(:user_followers)
  TwitterClasses.DBUtils.create_table(:user_notifications)
  TwitterClasses.DBUtils.create_table(:user_wall)
  TwitterClasses.DBUtils.add_to_table(:user_followers, {"user_followers",%{}})

  pid_keys = Map.keys(pid_to_handle)
  IO.puts("Setting the followers for users")
  Enum.each(pid_keys, fn x->
    TwitterClasses.Utils.set_followers(x, num_user)
  end)
  # user_foll = :ets.tab2list(:user_followers)
  # IO.inspect(user_foll)
  # Enum.each(1..5, fn x ->
  #   {:ok, temp} = Enum.fetch(Enum.take_random(handles,1),0)
  #   TwitterClasses.Utils.generate_tweet(temp)
  # end)

  # {tweet_hash, tweet_text} = TwitterClasses.Utils.get_random_tweet()

  # Register core users

  # Adding Simulator

  IO.puts("Triggering tweets")
  TwitterClasses.Simulator.trigger_tweet()

  receive do
    {:terminate_now, _pid} -> IO.puts("Terminating Supervisor")
    temp = GenServer.call(:tracker, :get_stats)
    IO.inspect(temp)
  end
  Supervisor.stop(TwitterClasses.Supervisor)
  final_time = Time.utc_now()
  time_diff = Time.diff(final_time, start_time, :millisecond)
  IO.puts("Total time taken #{time_diff/1000} seconds")

rescue
	e in ArgumentError ->  IO.puts(e)
	System.stop(1)
end
