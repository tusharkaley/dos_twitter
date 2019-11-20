
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
  :ets.new(:aux_info, [:named_table, read_concurrency: true])
  :ets.insert(:uaux_infosers, {:user_handles, handles})
  IO.puts("The number of children is #{inspect Supervisor.count_children(TwitterClasses.Supervisor)}")

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
	_e in ArgumentError ->  IO.puts("Script Failed!")
	System.stop(1)
end
