defmodule RegisterDeleteTests do
 
  use ExUnit.Case
  doctest TwitterClasses.Utils

  test "Test adding core users " do
    TwitterClasses.Utils.add_core_users(TwitterClasses.Core, 5, self(),10)
    assert Supervisor.count_children(TwitterClasses.Supervisor).active == 6
    Supervisor.stop(TwitterClasses.Supervisor)
  end

  test "Test Deleting a user" do
    TwitterClasses.Supervisor.start_link()
    TwitterClasses.Utils.add_core_users(TwitterClasses.Core, 5, self(),10)
    user_list = :ets.tab2list(:users)
    IO.puts("Delete debug")
    IO.inspect(user_list)
    {:ok, user_pids} = Enum.fetch(user_list, 0)
    IO.inspect(user_pids)
    user_pids = elem(user_pids, 0)
    TwitterClasses.Utils.delete_user(user_pids)
    {:ok, stored} = Enum.fetch(:ets.lookup(:users, user_pids), 0)
    assert elem(stored, 1) == false
    Supervisor.stop(TwitterClasses.Supervisor)
  end

  test "Subscribe to user's tweets" do
    #create data for table
    TwitterClasses.DBUtils.create_table(:aux_info)
    TwitterClasses.DBUtils.create_table(:user_followers)
    user_followers = %{"pid1"=>["pid2","pid3"]}
    TwitterClasses.DBUtils.add_to_table(:user_followers, {"user_followers",user_followers})
    subscribe_to_pid = "subscribe_to_pid"
    handle_to_pid = %{"follow_handle" => subscribe_to_pid}
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:handle_to_pid, handle_to_pid})
    Process.sleep(3000)
    TwitterClasses.Supervisor.start_link()
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 5, :start => {TwitterClasses.Core, :start_link, [6, "handler", 10]}, :restart => :transient,:type => :worker})
    TwitterClasses.Core.follow_user(child, "follow_handle")

    Process.sleep(3000)

    user_followers = TwitterClasses.DBUtils.get_from_table(:user_followers,"user_followers")
    user_followers = elem(user_followers,1)
    followers = Map.get user_followers, subscribe_to_pid
    assert Enum.member? followers,child
    Supervisor.stop(TwitterClasses.Supervisor)
  end

end
