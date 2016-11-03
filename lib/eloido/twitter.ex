defmodule Eloido.Twitter do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Eloido.Twitter.Connection, []),
    ]
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end
end
