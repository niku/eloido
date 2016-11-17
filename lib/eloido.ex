defmodule Eloido do
  @moduledoc """
  Callback functions to start eloido.
  """

  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = case Mix.env do
                 :test ->
                   # Do not connect to external servicies on testing environment.
                   [
                     Plug.Adapters.Cowboy.child_spec(:http, Eloido.Router, [], [])
                   ]
                 env when env in [:dev, :prod] ->
                   [
                     supervisor(Eloido.Twitter, [Map.new(Application.get_env(:eloido, :twitter))]),
                     supervisor(Eloido.Idobata, [Map.new(Application.get_env(:eloido, :idobata))]),
                     Plug.Adapters.Cowboy.child_spec(:http, Eloido.Router, [], [])
                   ]
               end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Eloido.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
