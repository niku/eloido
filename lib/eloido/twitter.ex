defmodule Eloido.Twitter do
  use Supervisor

  def start_link(%{} = config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def init(%{} = config) do
    children = [
      worker(Eloido.Twitter.Connection, [config]),
    ]
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end
end