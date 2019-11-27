defmodule CoreTests do
use ExUnit.Case
doctest TwitterClasses.Utils

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

    my_pid = self()
    TwitterClasses.Supervisor.start_link()
    {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 1, :start => {TwitterClasses.Core, :start_link, [1, "handle", 10]}, :restart => :transient,:type => :worker})
    TwitterClasses.Core.tweet(my_pid)
    # TwitterClasses.Utils.generate_tweet("handle")
    {"handle",tweets}= TwitterClasses.DBUtils.get_from_table(:user_tweets, "handle")
    last =  List.last tweets
    {a,b} = last
    assert String.equivalent?(b,"tweet")
  end

#   test "User Retweets" do
#     #data for test
#     TwitterClasses.DBUtils.create_table(:aux_info)
#     # Creating tweet tables
#   TwitterClasses.DBUtils.create_table(:tweets)
#   TwitterClasses.DBUtils.create_table(:hashtags)
#   TwitterClasses.DBUtils.create_table(:mentions)
#   TwitterClasses.DBUtils.create_table(:user_tweets)
#   TwitterClasses.DBUtils.create_table(:user_followers)
#   TwitterClasses.DBUtils.create_table(:user_notifications)
#     # add handles to the aux_info table
#     handles = ["handle"]
#     TwitterClasses.DBUtils.add_to_table(:aux_info, {:user_handles, handles})

#     my_pid = self()
#     TwitterClasses.Supervisor.start_link()
#     {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => 1, :start => {TwitterClasses.Core, :start_link, [2, "handle", 10]}, :restart => :transient,:type => :worker})
#     # TwitterClasses.Core.tweet(my_pid)

#     TwitterClasses.Utils.generate_tweet("handle")
#     {"handle",tweets}= TwitterClasses.DBUtils.get_from_table(:user_tweets, "handle")
#     last =  List.last tweets
#     {a,b} = last
#     assert String.equivalent?(b,"tweet")
#   end
    
end
