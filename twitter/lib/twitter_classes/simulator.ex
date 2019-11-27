defmodule TwitterClasses.Simulator do
  require Logger
    def start_link(action_id) do
      GenServer.start_link(__MODULE__, [action_id], [name: :simulator])
    end

    def init(init_arg) do
      {:ok, act_id} = Enum.fetch(init_arg, 0)
      node_state = %{"action_id" => act_id, "num_users"=>0}
      {:ok, node_state}
    end

    def trigger_tweet do
      alive_users =  :ets.match(:users, {:"$1",true,true,:"_",:"_"})
      size = trunc(length(alive_users) * 0.8)
      {low,high}= Enum.split alive_users, size
      high_freq_tweet(high)
      low_freq_tweet(low)
    end

    def high_freq_tweet(power_users) do
      Process.send_after(self(), {:high_freq_tweet, power_users}, 300)
    end

    def low_freq_tweet(slow_users) do
      Process.send_after(self(), {:low_freq_tweet, slow_users}, 1000)

    end

    def handle_info({:high_freq_tweet,power_users}) do
      user = Enum.random power_users
      #user TWEETS
      TwitterClasses.Core.tweet(user)
      high_freq_tweet(power_users)

    end

    def handle_info({:low_freq_tweet,slow_users}) do
      user = Enum.random slow_users
      #user TWEETS
      TwitterClasses.Core.tweet(user)
      low_freq_tweet(slow_users)
    end

    # Generate tweet
    # Tweet with mention
    # Tweet with hashtag
    # Tweet with hashtag and mention
    # Tweet with text

  end
