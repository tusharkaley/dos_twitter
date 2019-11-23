
dynamic_num_nodes = 10
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
  userid_to_handle = TwitterClasses.Utils.add_core_users(TwitterClasses.Core, num_user, self())
  handles = Map.values(userid_to_handle)

  # create the aux_info table
  TwitterClasses.DBUtils.create_table(:aux_info)

  # add handles to the aux_info table
  TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})

  # Creating tweet tables
  TwitterClasses.DBUtils.create_table(:tweets)
  TwitterClasses.DBUtils.create_table(:hashtags)
  TwitterClasses.DBUtils.create_table(:mentions)
  TwitterClasses.DBUtils.create_table(:user_tweets)

  # IO.puts("The number of children is #{inspect Supervisor.count_children(TwitterClasses.Supervisor)}")
  IO.puts "TWEET"
  Enum.each(1..5, fn x ->
    TwitterClasses.Utils.generate_tweet()
  end)
  IO.puts("HASHTAGS")
  IO.inspect(:ets.tab2list(:hashtags))
  IO.puts("MENTIONS")
  IO.inspect(:ets.tab2list(:mentions))
  IO.puts("TWEETS")
  IO.inspect(:ets.tab2list(:tweets))
  # Register core users

  # Adding Simulator

  #

  # receive do
  #   {:terminate_now, _pid} -> IO.puts("Terminating Supervisor")
  # end
  Supervisor.stop(TwitterClasses.Supervisor)
  final_time = Time.utc_now()
  time_diff = Time.diff(final_time, start_time, :millisecond)
  IO.puts("Total time taken #{time_diff} milliseconds")

rescue
	e in ArgumentError ->  IO.puts(e)
	System.stop(1)
end
