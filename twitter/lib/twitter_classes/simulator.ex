defmodule TwitterClasses.Simulator do
  require Logger
    def start_link() do
      GenServer.start_link(__MODULE__, [], [name: :simulator])
    end

    def init(_init_arg) do
      # {:ok, act_id} = Enum.fetch(init_arg, 0)
      node_state = %{}
      {:ok, node_state}
    end

    def trigger_tweet do
      alive_users =  :ets.match(:users, {:"$1",true,true,:_,:_})
      size = trunc(length(alive_users) * 0.8)
      {low,high}= Enum.split alive_users, size

      high_freq_tweet(high)
      low_freq_tweet(low)
    end

    def high_freq_tweet(power_users) do
      Process.send_after(:simulator, {:high_freq_tweet, power_users}, 300)
    end
    # def high_freq_tweet(power_users), do: Process.send_after(:simulator, {:high_freq_tweet,power_users}, 100)
    def low_freq_tweet(slow_users),  do: Process.send_after(:simulator, {:low_freq_tweet, slow_users}, 1000)
    # def low_freq_tweet(slow_users) do
    #   Process.send_after(self(), {:low_freq_tweet, slow_users}, 1000)

    # end

    def handle_info({:high_freq_tweet,power_users}, node_state) do
      user = Enum.random(power_users)
      {:ok, user} = Enum.fetch(user, 0)
      TwitterClasses.Core.tweet(user)
      high_freq_tweet(power_users)
      {:noreply, node_state}
    end

    def handle_info({:low_freq_tweet,slow_users}, node_state) do

      user = Enum.random(slow_users)
      {:ok, user} = Enum.fetch(user, 0)

      if TwitterClasses.Utils.toss_coin() == 1 do
        TwitterClasses.Core.tweet(user)
      else
        TwitterClasses.Core.retweet(user)
      end


      low_freq_tweet(slow_users)
      {:noreply, node_state}
    end

  end
