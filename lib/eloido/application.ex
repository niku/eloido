defmodule Eloido.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {
        Hobot,
        [
          Eloido.bot_name(),
          Eloido.adapter(),
          Eloido.handlers()
        ]
      }
    ]

    opts = [strategy: :one_for_one, name: Eloido.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
