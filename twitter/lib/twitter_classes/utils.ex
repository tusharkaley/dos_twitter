defmodule TwitterClasses.Utils do
  require Logger
  	@doc """
		Function to get the child Spec for the workers
  """
  @hashtags ['#basketballneverstops', '#lakers', '#tennisdrills', '#sports', '#cricketlife', '#cricketindia', '#dunk', '#indvsa', '#sport', '#nike', '#basket', '#cricketmatch', '#lovetennis', '#babolat', '#football', '#bleedblue', '#msd', '#baseball', '#bball', '#kohli', '#cricketforlife', '#follow', '#instagram', '#follow', '#crickets', '#tenniscoaching', '#ball', '#lavercup', '#basketball', '#jordan', '#hitman', '#k', '#tennispractice', '#rafaelnadal', '#tennislessons', '#tennislover', '#love', '#wilson', '#nadal', '#viratians', '#federer', '#tenniskids', '#cricketnews', '#cricketfever', '#nbabasketball', '#like', '#lebronjames', '#odi', '#stevesmith', '#hoops', '#tennisvideo', '#cali', '#virat', '#ballislife', '#hardikpandya', '#cricketworld', '#rcb', '#england', '#itf', '#fitness', '#cpl', '#englandcricket', '#ashes', '#australianopen', '#tennisball', '#atpworldtour', '#psl', '#indvssa', '#atptour', '#like', '#djokovic', '#southafrica', '#adidas', '#nba', '#soccer', '#basketballislife', '#memes', '#bhfyp', '#golf', '#tennisrunsinourblood', '#soccer', '#baloncesto', '#x', '#klrahul', '#nfl', '#rolandgarros', '#bangladesh', '#basketballtraining', '#tennisaddict', '#lebron']
  @words ['comb','snow','condition','example','check','reply','choke','signal','stone','ladybug','trick','smash','advice','birthday','comparison','imaginary','loose','glove','needle','recondite','waste','ugliest','ask','sound','twist','whole','well-groomed','exuberant','relieved','resolute','placid','unable','ruthless','fair','five','roasted','safe','even','slow','parallel','nebulous','political','obsolete','various','mammoth','eggnog','sound','twist','stove','hill','school','seed','horn','knowledge','pets','shop','picture','expansion','minute','parcel','end','doll','tongue','detail','ticket','pass','chew','strap','appear','scrub','applaud','carry','wriggle','stamp','bow','dance','coil','fill','soak','trip','grip','accept','snow','request','scrape','considering','about','since','on','underneath','with','under','anti','besides','excluding','following','regarding','amid','before','towards','taillike','fishbowl','comedown','cannot','slumlord','noisemaker','blackjack','forestall','railroad','schoolbus','paycheck','watershed','daybook','sheepskin','candlelight','onetime','waybill','eyeballs','taillight','snowbird','equally','joyously','zealously','very','merrily','nearly','else','easily','frightfully','justly','reluctantly','enormously','triumphantly','safely','upward','constantly','zestily','painfully','nervously','blissfully']

  def add_core_users(child_class, num_nodes, script_pid) do
    :ets.new(:users, [:named_table, read_concurrency: true])
    {:ok, agg} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => :tracker, :start => {TwitterClasses.Tracker, :start_link, [num_nodes, script_pid]}, :restart => :transient,:type => :worker})
    Logger.debug("Added Tracker on #{inspect agg}")
    map = Enum.reduce(1..num_nodes, %{},  fn x, acc ->
      handle = get_random_handle()
      {:ok, child} = Supervisor.start_child(TwitterClasses.Supervisor, %{:id => x, :start => {child_class, :start_link, [x, handle]}, :restart => :transient,:type => :worker})
      add_user(handle, x, child)
      Logger.debug("User added to table #{inspect :ets.lookup(:users, handle)}")
      Map.put(acc, x, handle)
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
    :crypto.strong_rand_bytes(len) |> Base.url_encode64 |> binary_part(0, len)
  end
  def add_user(handle, id, pid) do
    # Storing users in a table in
    :ets.insert(:users, {handle, true, id, pid})
  end

  def delete_user(handle) do
    :ets.delete(:users, handle)
    :ets.insert(:users, {handle, false})
  end

  def generate_tweet() do
    tweets_store = %{"username" => "tweet"}
    :ets.new(:tweets_store, [:named_table, read_concurrency: true])
    :ets.insert(:tweets_store, {"tweets_store", pid_to_id})
  end

  def set_subscribers(username) do
    :ets.new(:subscribers_list,[:named_table,read_concurrency: true])
    :ets.insert(:subscribers_list, subscribers)
  end

end
