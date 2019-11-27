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

  test "Query with hashtag" do
    
  end

  test "Subscribe to user's tweets" do
    #create data for table
    my_pid = "my_pid"
    TwitterClasses.DBUtils.create_table(:user_followers)
    user_followers = %{"pid1"=>["pid2","pid3"], "pid2"=>["pid1","pid3"]}
    TwitterClasses.DBUtils.add_to_table(:user_followers, {"user_followers",user_followers})

    subscribe_to_pid = "subscribe_to_pid"
    TwitterClasses.Utils.follow_user(my_pid, subscribe_to_pid)

    user_followers = TwitterClasses.DBUtils.get_from_table(:user_followers,"user_followers")
    user_followers = elem(user_followers,1)
    followers = Map.get user_followers, subscribe_to_pid
    assert Enum.member? followers,my_pid
  end

  # test "User tweets" do
  #   my_pid = "my_pid"
  #   TwitterClasses.Supervisor.start_link()
  #   {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 1, :start => {TwitterClasses.Core, :start_link, [1, "handle", 10]}, :restart => :transient,:type => :worker})
  #   TwitterClasses.Core.tweet(my_pid)
  #   tweets = TwitterClasses.DBUtils.get_from_table(:user_tweets, "handle")
  #   last =  List.last tweets != nil
  #   assert last
  # end

  # test "User retweets" do
  #   TwitterClasses.Core.retweet(my_pid)
    
  # end

end
