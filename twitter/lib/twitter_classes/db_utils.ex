defmodule TwitterClasses.DBUtils do
  def create_table(table_name) do
    :ets.new(table_name, [:named_table, read_concurrency: true])
  end

  def get_from_table(table_name, key) do
    res = :ets.lookup(table_name, key)
    res = if length(res)>0 do
        {:ok, res} = Enum.fetch(res, 0)
        res = elem(res, 1)
        res
    else
        res
    end
    res

  end

  def add_to_table(table_name, data) do
    :ets.insert(table_name, data)
  end

  def delete_from_table(table_name, key) do
    :ets.delete(table_name, key)
  end

  def add_or_update(table, key, entry) do
    IO.puts(is_atom(table))
    tweets = TwitterClasses.DBUtils.get_from_table(table, key)
    if length(tweets) > 0 do
      stored_mentions = TwitterClasses.DBUtils.get_from_table(table, key)
      stored_mentions = stored_mentions ++[entry]
      TwitterClasses.DBUtils.add_to_table(table, {key, stored_mentions})
    else
      TwitterClasses.DBUtils.add_to_table(table, {key, [entry]})
    end
  end
end
