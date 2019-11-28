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
    Process.sleep(4000)
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
    Process.sleep(5000)
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

  test "Get my notifications" do
    TwitterClasses.DBUtils.create_table(:user_notifications)
    TwitterClasses.Supervisor.start_link()
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 5, :start => {TwitterClasses.Core, :start_link, [6, "handler", 10]}, :restart => :transient,:type => :worker})
   #Data for the test
   data = {child,["tweet1,tweet2"]}
    TwitterClasses.DBUtils.add_to_table(:user_notifications,data)
    Process.sleep(2000)
    tweets = TwitterClasses.Core.get_my_notifications(child)
    Process.sleep(4000)
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
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 5, :start => {TwitterClasses.Core, :start_link, [6, "handler", 10]}, :restart => :transient,:type => :worker})
    TwitterClasses.DBUtils.create_table(:hashtags)
    #Data for table
    tweet_hash = TwitterClasses.Utils.get_tweet_hash("#gogators UF rocks #swamp")
    hashtags = ["#gogators","#swamp"]
    if length(hashtags)>0 do
        Enum.each(hashtags, fn x ->
          TwitterClasses.DBUtils.add_or_update(:hashtags, x, tweet_hash)
        end)
      end
    tweet= TwitterClasses.Utils.query_hashtag("#gogators")
    assert tweet == [tweet_hash]
    Supervisor.stop(TwitterClasses.Supervisor)

  end

  test "Query hashtag 2" do
    TwitterClasses.Supervisor.start_link()
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 5, :start => {TwitterClasses.Core, :start_link, [6, "handler", 10]}, :restart => :transient,:type => :worker})
    TwitterClasses.DBUtils.create_table(:hashtags)
    #Data for table
    tweet_hash = TwitterClasses.Utils.get_tweet_hash("#gogators UF rocks #swamp")
    hashtags = ["#gogators","#swamp"]
    if length(hashtags)>0 do
        Enum.each(hashtags, fn x ->
          TwitterClasses.DBUtils.add_or_update(:hashtags, x, tweet_hash)
        end)
      end
    tweet= TwitterClasses.Utils.query_hashtag("#swamp")
    assert tweet == [tweet_hash]
    Supervisor.stop(TwitterClasses.Supervisor)

  end

  test "Query Mention" do
    TwitterClasses.Supervisor.start_link()
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 5, :start => {TwitterClasses.Core, :start_link, [6, "handler", 10]}, :restart => :transient,:type => :worker})
    TwitterClasses.DBUtils.create_table(:mentions)
    tweet_hash = TwitterClasses.Utils.get_tweet_hash("@gators UF rocks")
    TwitterClasses.DBUtils.add_to_table(:mentions, {"@gators", tweet_hash})
    tweet= TwitterClasses.Utils.query_mentions("@gators")
    Process.sleep(100)
    assert tweet == tweet_hash
    assert true
    Supervisor.stop(TwitterClasses.Supervisor)

  end


end
