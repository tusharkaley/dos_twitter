defmodule UtilsTests do

  use ExUnit.Case
  doctest TwitterClasses.Utils

  test "Test mentions entry for tweet" do
    TwitterClasses.DBUtils.create_table(:aux_info)
    TwitterClasses.DBUtils.create_table(:tweets)
    TwitterClasses.DBUtils.create_table(:hashtags)
    TwitterClasses.DBUtils.create_table(:mentions)
    TwitterClasses.DBUtils.create_table(:user_tweets)
    handles = ["@abcd", "@efghi", "@jklm", "@nopqrstuvwx", "@yz", "@nextLine"]
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})
    {tweet, hashtags, mentions, tweet_hash} = TwitterClasses.Utils.generate_tweet("@gators", ["@cise"], ["#frenchfries"])
    Process.sleep(100)
    mentions = TwitterClasses.DBUtils.get_from_table(:mentions, "@cise")

    IO.inspect(mentions)
    assert {"@cise", [tweet_hash]} == mentions
    # Supervisor.stop(TwitterClasses.Supervisor)
  end

  test "Test hashtag entry for tweet" do
    TwitterClasses.DBUtils.create_table(:aux_info)
    TwitterClasses.DBUtils.create_table(:tweets)
    TwitterClasses.DBUtils.create_table(:hashtags)
    TwitterClasses.DBUtils.create_table(:mentions)
    TwitterClasses.DBUtils.create_table(:user_tweets)
    handles = ["@abcd", "@efghi", "@jklm", "@nopqrstuvwx", "@yz", "@nextLine"]
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})
    {tweet, hashtags, mentions, tweet_hash} = TwitterClasses.Utils.generate_tweet("@gators", ["@cise"], ["#frenchfries"])
    Process.sleep(100)
    hashtag = TwitterClasses.DBUtils.get_from_table(:hashtags, "#frenchfries")
    assert {"#frenchfries", [tweet_hash]} == hashtag
  end

  test "Test tweets table entry for tweet" do
    TwitterClasses.DBUtils.create_table(:aux_info)
    TwitterClasses.DBUtils.create_table(:tweets)
    TwitterClasses.DBUtils.create_table(:hashtags)
    TwitterClasses.DBUtils.create_table(:mentions)
    TwitterClasses.DBUtils.create_table(:user_tweets)
    handles = ["@abcd", "@efghi", "@jklm", "@nopqrstuvwx", "@yz", "@nextLine"]
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})
    {tweet, hashtags, mentions, tweet_hash} = TwitterClasses.Utils.generate_tweet("@gators", ["@cise"], ["#frenchfries"])
    Process.sleep(100)
    tweet_q = TwitterClasses.DBUtils.get_from_table(:tweets, tweet_hash)
    assert {tweet_hash, tweet} == tweet_q
  end

  test "Test user tweets table entry for tweet" do
    TwitterClasses.DBUtils.create_table(:aux_info)
    TwitterClasses.DBUtils.create_table(:tweets)
    TwitterClasses.DBUtils.create_table(:hashtags)
    TwitterClasses.DBUtils.create_table(:mentions)
    TwitterClasses.DBUtils.create_table(:user_tweets)
    handles = ["@abcd", "@efghi", "@jklm", "@nopqrstuvwx", "@yz", "@nextLine"]
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})
    {tweet, hashtags, mentions, tweet_hash} = TwitterClasses.Utils.generate_tweet("@gators", ["@cise"], ["#frenchfries"])
    Process.sleep(100)
    tweet_q = TwitterClasses.DBUtils.get_from_table(:user_tweets, "@gators")
    assert {"@gators",[{tweet_hash, "tweet"}]} == tweet_q
  end

  test "Get Random handle test" do
    handle = TwitterClasses.Utils.get_random_handle()
    assert String.length(handle)>=2

  end

  test "Test set followers" do
    TwitterClasses.Supervisor.start_link()
    pid_to_handle = TwitterClasses.Utils.add_core_users(TwitterClasses.Core, 5, self(),10)
    handles = Map.values(pid_to_handle)

    # Create the aux_info table
    TwitterClasses.DBUtils.create_table(:aux_info)
    TwitterClasses.DBUtils.create_table(:user_followers)
    # add handles to the aux_info table
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})
    TwitterClasses.DBUtils.add_to_table(:aux_info, {:pid_to_handle, pid_to_handle})
    TwitterClasses.DBUtils.add_to_table(:user_followers, {"user_followers",%{}})
    user_list = :ets.tab2list(:users)
    # IO.inspect(user_list)
    {:ok, user_pids} = Enum.fetch(user_list, 0)
    # IO.inspect(user_pids)
    user_pids = elem(user_pids, 0)
    TwitterClasses.Utils.set_followers(user_pids, 5)
    Process.sleep(100)
    user_followers = TwitterClasses.DBUtils.get_from_table(:user_followers, "user_followers")
    user_followers = elem(user_followers, 1)
    assert Map.has_key?(user_followers, user_pids)
    Supervisor.stop(TwitterClasses.Supervisor)
  end

end
