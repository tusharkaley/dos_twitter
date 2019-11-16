defmodule TwitterApp do
	use Application
@moduledoc """
	Tapestry app which triggers the Supervisor on start
"""
  	@doc """
    	Function to start the Application
  	"""
	def start(_type, _args) do
    	{:ok, _pid} = TwitterClasses.Supervisor.start_link()
  	end

end
