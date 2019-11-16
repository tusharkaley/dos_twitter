import Supervisor.Spec

defmodule TwitterClasses.Supervisor do
	use Supervisor
	require Logger
@moduledoc """
"""
		@doc """
		Client function which triggers the Supervisor start
		"""
		def start_link() do
			Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
		end

    def init(_nums_range) do

			supervise([], strategy: :one_for_one)

		end

end
