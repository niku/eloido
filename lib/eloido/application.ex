defmodule Eloido.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Eloido.Worker.start_link(arg1, arg2, arg3)
      # worker(Eloido.Worker, [arg1, arg2, arg3]),
      Plug.Adapters.Cowboy.child_spec(:http, Eloido.Router, [], []),
      worker(Hobot.Input.TwitterStreaming, [{Eloido.twitter_load_oauth_token,
                                             Eloido.twitter_load_streaming_param,
                                             Eloido.twitter_topic}]),
      worker(Hobot.Output.HTTP, [Eloido.http_topic_map,
                                 Eloido.http_plugin_options])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Eloido.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
