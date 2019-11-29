defmodule CoreTests do
use ExUnit.Case
doctest TwitterClasses.Core

 test "User tweets" do
    #data for test
    TwitterClasses.DBUtils.create_table(:aux_info)
    # Creating tweet tables
    TwitterClasses.DBUtils.create_table(:tweets)
    TwitterClasses.DBUtils.create_table(:hashtags)
    TwitterClasses.DBUtils.create_table(:mentions)
    TwitterClasses.DBUtils.create_table(:user_tweets)
    TwitterClasses.DBUtils.create_table(:user_followers)
    TwitterClasses.DBUtils.create_table(:user_notifications)
    # add handles to the aux_info table
    handles = ["handle"]
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})

    TwitterClasses.Supervisor.start_link()
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 3, :start => {TwitterClasses.Core, :start_link, [2, "handle", 10]}, :restart => :transient,:type => :worker})

    TwitterClasses.Core.tweet(child)
    Process.sleep(1000)
    {"handle",tweets}= TwitterClasses.DBUtils.get_from_table(:user_tweets, "handle")
    last =  List.last tweets
    {a,b} = last
    assert String.equivalent?(b,"tweet")
    Supervisor.stop(TwitterClasses.Supervisor)
  end

  test "User retweets" do
    #data for test
    TwitterClasses.DBUtils.create_table(:aux_info)
    # Creating tweet tables
    TwitterClasses.DBUtils.create_table(:tweets)
    TwitterClasses.DBUtils.create_table(:hashtags)
    TwitterClasses.DBUtils.create_table(:mentions)
    TwitterClasses.DBUtils.create_table(:user_tweets)
    TwitterClasses.DBUtils.create_table(:user_followers)
    TwitterClasses.DBUtils.create_table(:user_notifications)
    # add handles to the aux_info table
    handles = ["handle"]
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})

    TwitterClasses.Supervisor.start_link()
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 1, :start => {TwitterClasses.Core, :start_link, [4, "handler", 10]}, :restart => :transient,:type => :worker})

    TwitterClasses.DBUtils.add_to_table(:tweets, {"tweet_hash", "tweet"})
    TwitterClasses.Core.retweet(child)
    Process.sleep(1000)
    {"handler",tweets}= TwitterClasses.DBUtils.get_from_table(:user_tweets, "handler")
    last =  List.last tweets
    {a,b} = last
    assert String.equivalent?(b,"retweet")
    Supervisor.stop(TwitterClasses.Supervisor)
    # assert true
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
    Process.sleep(1000)
    TwitterClasses.Supervisor.start_link()
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 5, :start => {TwitterClasses.Core, :start_link, [6, "handler", 10]}, :restart => :transient,:type => :worker})
    TwitterClasses.Core.follow_user(child, "follow_handle")

    Process.sleep(100)

    user_followers = TwitterClasses.DBUtils.get_from_table(:user_followers,"user_followers")
    user_followers = elem(user_followers,1)
    followers = Map.get user_followers, subscribe_to_pid
    assert Enum.member? followers,child
    Supervisor.stop(TwitterClasses.Supervisor)
  end

  test "Get my notifications" do
    TwitterClasses.DBUtils.create_table(:user_notifications)
    TwitterClasses.Supervisor.start_link()
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 5, :start => {TwitterClasses.Core, :start_link, [6, "handler", 10]}, :restart => :transient,:type => :worker})
   #Data for the test
   data = {child,["tweet1,tweet2"]}
    TwitterClasses.DBUtils.add_to_table(:user_notifications,data)
    Process.sleep(100)
    tweets = TwitterClasses.Core.get_my_notifications(child)
    # Process.sleep(4000)
    assert data == tweets
    Supervisor.stop(TwitterClasses.Supervisor)
  end

  test "Get all tweets" do
    TwitterClasses.Supervisor.start_link()
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 5, :start => {TwitterClasses.Core, :start_link, [6, "handler", 10]}, :restart => :transient,:type => :worker})
    #Data for table
    data = {child,["tweet1,tweet2"]}
    TwitterClasses.DBUtils.create_table(:user_wall)
    TwitterClasses.DBUtils.add_to_table(:user_wall,data)
    Process.sleep(100)
    tweets=  TwitterClasses.Core.get_all_tweets(child)
    assert data == tweets
    Supervisor.stop(TwitterClasses.Supervisor)
  end


  test "Query hashtag 1" do
    TwitterClasses.Supervisor.start_link()
    {:ok, agg} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => :tracker, :start => {TwitterClasses.Tracker, :start_link, [5, self()]}, :restart => :transient,:type => :worker})
    TwitterClasses.DBUtils.create_table(:hashtags)
    #Data for table
    tweet_hash = TwitterClasses.Utils.get_tweet_hash("#gogators UF rocks #swamp")
    hashtags = ["#gogators","#swamp"]
    if length(hashtags)>0 do
        Enum.each(hashtags, fn x ->
          TwitterClasses.DBUtils.add_or_update(:hashtags, x, tweet_hash)
        end)
      end
    tweet = TwitterClasses.Tracker.query_hashtag("#gogators")
    assert tweet == [tweet_hash]
    Supervisor.stop(TwitterClasses.Supervisor)

  end

  test "Query hashtag 2" do
    TwitterClasses.Supervisor.start_link()
    {:ok, agg} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => :tracker, :start => {TwitterClasses.Tracker, :start_link, [5, self()]}, :restart => :transient,:type => :worker})
    TwitterClasses.DBUtils.create_table(:hashtags)
    #Data for table
    tweet_hash = TwitterClasses.Utils.get_tweet_hash("#gogators UF rocks #swamp")
    hashtags = ["#gogators","#swamp"]
    if length(hashtags)>0 do
        Enum.each(hashtags, fn x ->
          TwitterClasses.DBUtils.add_or_update(:hashtags, x, tweet_hash)
        end)
      end
    tweet = TwitterClasses.Tracker.query_hashtag("#swamp")
    assert tweet == [tweet_hash]
    Supervisor.stop(TwitterClasses.Supervisor)

  end

  test "Query Mention" do
    TwitterClasses.Supervisor.start_link()
    {:ok, agg} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => :tracker, :start => {TwitterClasses.Tracker, :start_link, [5, self()]}, :restart => :transient,:type => :worker})
    TwitterClasses.DBUtils.create_table(:mentions)
    tweet_hash = TwitterClasses.Utils.get_tweet_hash("@gators UF rocks")
    TwitterClasses.DBUtils.add_to_table(:mentions, {"@gators", tweet_hash})
    Process.sleep(1000)
    tweets = TwitterClasses.Tracker.query_mention("@gators")
    Process.sleep(100)
    assert tweets == tweet_hash
    # assert true
    Supervisor.stop(TwitterClasses.Supervisor)

  end

  test "Tweet when subscriber is not live" do
    #data for test
    TwitterClasses.DBUtils.create_table(:aux_info)
    # Creating tweet tables
    TwitterClasses.DBUtils.create_table(:tweets)
    TwitterClasses.DBUtils.create_table(:hashtags)
    TwitterClasses.DBUtils.create_table(:mentions)
    TwitterClasses.DBUtils.create_table(:user_tweets)
    TwitterClasses.DBUtils.create_table(:user_followers)
    TwitterClasses.DBUtils.create_table(:user_notifications)
    TwitterClasses.DBUtils.create_table(:user_wall)
    TwitterClasses.DBUtils.create_table(:users)

    
    # add handles to the aux_info table
    user_handle = "user"
    follower_handle = "follower"
    handles = [user_handle, follower_handle]
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})
    
 

    TwitterClasses.Supervisor.start_link()

    {:ok, pid1} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 1, :start => {TwitterClasses.Core, :start_link, [2, user_handle, 10]}, :restart => :transient,:type => :worker})
    {:ok, pid2} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 4, :start => {TwitterClasses.Core, :start_link, [3, follower_handle, 10]}, :restart => :transient,:type => :worker})
    {:ok, agg} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => :tracker, :start => {TwitterClasses.Tracker, :start_link, [5, "tracker"]}, :restart => :transient,:type => :worker})
   
    TwitterClasses.DBUtils.add_to_table(:users, {pid2, true, false, 1, follower_handle})
    handle_to_pid = %{follower_handle=> pid2, user_handle => pid1}
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:handle_to_pid, handle_to_pid})
    #user 2 follows 1
    IO.puts "Testing "
    user_followers = %{pid1 => [pid2]}
    TwitterClasses.DBUtils.add_to_table(:user_followers, {"user_followers",user_followers})
    TwitterClasses.Core.tweet(pid1)
    
    Process.sleep(100)

    {pid,wall} = TwitterClasses.DBUtils.get_from_table(:user_wall, pid2)
    {hash,user_id} = List.first wall
    assert user_id == pid1 and pid == pid2
    Supervisor.stop(TwitterClasses.Supervisor)
  end

  
  test "Tweet when subscriber is live" do
    #data for test
    TwitterClasses.DBUtils.create_table(:aux_info)
    # Creating tweet tables
    TwitterClasses.DBUtils.create_table(:tweets)
    TwitterClasses.DBUtils.create_table(:hashtags)
    TwitterClasses.DBUtils.create_table(:mentions)
    TwitterClasses.DBUtils.create_table(:user_tweets)
    TwitterClasses.DBUtils.create_table(:user_followers)
    TwitterClasses.DBUtils.create_table(:user_notifications)
    TwitterClasses.DBUtils.create_table(:user_wall)
    TwitterClasses.DBUtils.create_table(:users)

    
    # add handles to the aux_info table
    user_handle = "user"
    follower_handle = "follower"
    handles = [user_handle, follower_handle]
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})
    
    TwitterClasses.Supervisor.start_link()

    {:ok, pid1} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 7, :start => {TwitterClasses.Core, :start_link, [9, user_handle, 10]}, :restart => :transient,:type => :worker})
    {:ok, pid2} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 8, :start => {TwitterClasses.Core, :start_link, [0, follower_handle, 10]}, :restart => :transient,:type => :worker})
    {:ok, agg} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => :tracker, :start => {TwitterClasses.Tracker, :start_link, [1, "track"]}, :restart => :transient,:type => :worker})
   
    TwitterClasses.DBUtils.add_to_table(:users, {pid2, true, true, 1, follower_handle})
    handle_to_pid = %{follower_handle=> pid2, user_handle => pid1}
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:handle_to_pid, handle_to_pid})
    #user 2 follows 1
    IO.puts "Testing "
    user_followers = %{pid1 => [pid2]}
    TwitterClasses.DBUtils.add_to_table(:user_followers, {"user_followers",user_followers})
    TwitterClasses.Core.tweet(pid1)
    
    Process.sleep(100)
    IO.puts "Heree"
    IO.inspect TwitterClasses.DBUtils.get_from_table(:user_wall, pid2)
    {pid,wall} = TwitterClasses.DBUtils.get_from_table(:user_wall, pid2)
    {hash,user_id} = List.first wall
    assert user_id == pid1 and pid == pid2
    Supervisor.stop(TwitterClasses.Supervisor)
  end

end
