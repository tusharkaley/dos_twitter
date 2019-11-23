defmodule TwitterClasses.Utils do
  require Logger
  	@doc """
		Function to get the child Spec for the workers
  """
  @hashtags ['#basketballneverstops', '#lakers', '#tennisdrills', '#sports', '#cricketlife', '#cricketindia', '#dunk', '#indvsa', '#sport', '#nike', '#basket', '#cricketmatch', '#lovetennis', '#babolat', '#football', '#bleedblue', '#msd', '#baseball', '#bball', '#kohli', '#cricketforlife', '#follow', '#instagram', '#follow', '#crickets', '#tenniscoaching', '#ball', '#lavercup', '#basketball', '#jordan', '#hitman', '#k', '#tennispractice', '#rafaelnadal', '#tennislessons', '#tennislover', '#love', '#wilson', '#nadal', '#viratians', '#federer', '#tenniskids', '#cricketnews', '#cricketfever', '#nbabasketball', '#like', '#lebronjames', '#odi', '#stevesmith', '#hoops', '#tennisvideo', '#cali', '#virat', '#ballislife', '#hardikpandya', '#cricketworld', '#rcb', '#england', '#itf', '#fitness', '#cpl', '#englandcricket', '#ashes', '#australianopen', '#tennisball', '#atpworldtour', '#psl', '#indvssa', '#atptour', '#like', '#djokovic', '#southafrica', '#adidas', '#nba', '#soccer', '#basketballislife', '#memes', '#bhfyp', '#golf', '#tennisrunsinourblood', '#soccer', '#baloncesto', '#x', '#klrahul', '#nfl', '#rolandgarros', '#bangladesh', '#basketballtraining', '#tennisaddict', '#lebron']
  @words ['nervously', 'cannot', 'knowledge', 'comedown', 'towards', 'stamp', 'horn', 'parcel', 'anti', 'shop', 'joyously', 'ticket', 'recondite', 'frightfully', 'picture', 'forestall', 'nebulous', 'scrub', 'under', 'very', 'applaud', 'needle', 'eggnog', 'else', 'constantly', 'fair', 'relieved', 'five', 'on', 'waste', 'minute', 'political', 'slow', 'candlelight', 'signal', 'choke', 'exuberant', 'obsolete', 'blissfully', 'reply', 'advice', 'about', 'detail', 'even', 'hill', 'doll', 'with', 'since', 'placid', 'triumphantly', 'daybook', 'coil', 'roasted', 'noisemaker', 'paycheck', 'zestily', 'birthday', 'nearly', 'onetime', 'wriggle', 'snow', 'safely', 'zealously', 'pets', 'grip', 'appear', 'strap', 'comparison', 'ask', 'eyeballs', 'glove', 'schoolbus', 'twist', 'whole', 'snow', 'comb', 'merrily', 'snowbird', 'besides', 'check', 'taillight', 'smash', 'excluding', 'sheepskin', 'twist', 'parallel', 'expansion', 'dance', 'mammoth', 'railroad', 'fishbowl', 'sound', 'waybill', 'school', 'considering', 'imaginary', 'painfully', 'underneath', 'blackjack', 'ladybug', 'request', 'upward', 'well-groomed', 'end', 'example', 'following', 'stove', 'amid', 'bow', 'enormously', 'safe', 'carry', 'accept', 'tongue', 'fill', 'ruthless', 'loose', 'ugliest', 'trick', 'watershed', 'reluctantly', 'justly', 'equally', 'various', 'unable', 'sound', 'slumlord', 'condition', 'seed', 'trip', 'pass', 'scrape', 'soak', 'before', 'resolute', 'easily', 'stone', 'taillike', 'chew', 'regarding']

  def add_core_users(child_class, num_nodes, script_pid, num_msgs) do

    TwitterClasses.DBUtils.create_table(:users)
    {:ok, agg} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => :tracker, :start => {TwitterClasses.Tracker, :start_link, [num_nodes, script_pid]}, :restart => :transient,:type => :worker})
    Logger.debug("Added Tracker on #{inspect agg}")
    map = Enum.reduce(1..num_nodes, %{},  fn x, acc ->
      handle = get_random_handle()
      {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => x, :start => {child_class, :start_link, [x, handle, num_msgs]}, :restart => :transient,:type => :worker})
      add_user(handle, x, child)
      Logger.debug("User added to table #{inspect :ets.lookup(:users, handle)}")
      Map.put(acc, child, handle)
    end)
    map
  end

  def register_core_users do
    # What data would a user have
    # Twitter handle
    :tushar
  end

  def get_random_handle() do
    len = Enum.random(5..20)
    temp = :crypto.strong_rand_bytes(len) |> Base.url_encode64 |> binary_part(0, len)
    "@"<>temp
  end
  def add_user(handle, id, pid) do
    # Storing users in a table in
    TwitterClasses.DBUtils.add_to_table(:users, {pid, true, true, id, handle})
  end

  def delete_user(pid) do

    value = TwitterClasses.DBUtils.get_from_table(:users, pid)
    value = put_elem(value, 1, false)
    TwitterClasses.DBUtils.delete_from_table(:users, pid)
    TwitterClasses.DBUtils.add_to_table(:users, value)

  end



  def generate_tweet() do
      rand_num = Enum.random(1..7)
      handles = TwitterClasses.DBUtils.get_from_table(:aux_info, :user_handles)
      handles = elem(handles, 1)
      IO.inspect(handles)
      tweet = Enum.take_random(@words, rand_num)
      mentions = if toss_coin() == 1 do
        Enum.take_random(handles, 1)
      else
        []
      end

      tweet = if length(mentions) > 0 do
        tweet ++ mentions
      else
        tweet
      end

      rand_num = Enum.random(1..10)

      tweet = tweet ++ Enum.take_random(@words, rand_num)

      hashtags = if toss_coin() == 1 do
        rand_num = Enum.random(1..4)
        Enum.take_random(@hashtags, rand_num)
      else
        []
      end

      tweet = if length(hashtags) > 0 do
        tweet ++ hashtags
      else
        tweet
      end
      IO.inspect(hashtags)
      IO.inspect(mentions)
      tweet = Enum.join(tweet, " ")
      IO.puts(tweet)
      tweet_hash = get_tweet_hash(tweet)
      TwitterClasses.DBUtils.add_to_table(:tweets, {tweet_hash, tweet})
      TwitterClasses.Utils.save_mentions_hashtags_to_table(:hashtags, tweet_hash, hashtags)
      TwitterClasses.Utils.save_mentions_hashtags_to_table(:mentions, tweet_hash, mentions)
      {tweet, hashtags, mentions}
  end

  def toss_coin() do
    Enum.random([0,1])
  end
  def get_tweet_hash(tweet) do
    tweet_hash = :crypto.hash(:sha, tweet) |> Base.encode16
    tweet_hash = String.slice(tweet_hash, -9, 8)
    tweet_hash
  end
  def save_mentions_hashtags_to_table(table, tweet_hash, entity) do
    if length(entity)>0 do
      Enum.each(entity, fn x ->
        TwitterClasses.DBUtils.add_or_update(table, x, tweet_hash)
      end)

    end
  end


end
