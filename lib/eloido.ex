defmodule Eloido do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Eloido.Worker, [arg1, arg2, arg3]),
      supervisor(Eloido.Twitter, [Map.new(Application.get_env(:eloido, :twitter))]),
      supervisor(Eloido.Idobata, [Map.new(Application.get_env(:eloido, :idobata))]),
      Plug.Adapters.Cowboy.child_spec(:http, Eloido.Router, [], [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Eloido.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
