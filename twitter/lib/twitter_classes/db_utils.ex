defmodule TwitterClasses.DBUtils do
  def create_table(table_name) do
    :ets.new(table_name, [:named_table, :public, read_concurrency: true])
  end

  def get_from_table(table_name, key) do
    res = :ets.lookup(table_name, key)
    res = if length(res)>0 do
        {:ok, res} = Enum.fetch(res, 0)
        res
    else      
        {}
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
    tweets = TwitterClasses.DBUtils.get_from_table(table, key)
    if tuple_size(tweets) > 0 do
      tweets = elem(tweets, 1)
      tweets = tweets ++[entry]
      TwitterClasses.DBUtils.add_to_table(table, {key, tweets})
    else
      TwitterClasses.DBUtils.add_to_table(table, {key, [entry]})
    end
  end
end
