defmodule RegisterDeleteTests do
  use ExUnit.Case
  doctest TwitterClasses.Utils

  test "Test adding core users " do
    TwitterClasses.Utils.add_core_users(TwitterClasses.Core, 5, self())
    assert Supervisor.count_children(TwitterClasses.Supervisor).active == 6
    Supervisor.stop(TwitterClasses.Supervisor)
  end

  test "Test Deleting a user" do
    TwitterClasses.Supervisor.start_link()
    TwitterClasses.Utils.add_core_users(TwitterClasses.Core, 5, self())
    user_list = :ets.tab2list(:users)
    {:ok, user_handle} = Enum.fetch(user_list, 0)
    user_handle = elem(user_handle, 0)
    TwitterClasses.Utils.delete_user(user_handle)
    {:ok, stored} = Enum.fetch(:ets.lookup(:users, user_handle), 0)
    assert elem(stored, 1) == false
    Supervisor.stop(TwitterClasses.Supervisor)
  end

end
