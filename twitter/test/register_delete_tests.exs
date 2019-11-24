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

end
