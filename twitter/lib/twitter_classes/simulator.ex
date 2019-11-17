defmodule TwitterClasses.Simulator do
  require Logger
    def start_link(action_id) do
      GenServer.start_link(__MODULE__, [action_id])
    end

    def init(init_arg) do
      {:ok, act_id} = Enum.fetch(init_arg, 0)
      node_state = %{"action_id" => act_id}
      {:ok, node_state}
    end

    def schedule() do
      Process.send_after(self(), :bump, 300)
    end

    def handle_info(:bump) do
      # This function will periodically
      schedule()
    end

    # Generate tweet
    # Tweet with mention
    # Tweet with hashtag
    # Tweet with hashtag and mention
    # Tweet with text

  end
