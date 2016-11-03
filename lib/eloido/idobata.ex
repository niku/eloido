defmodule Eloido.Idobata do
  use Supervisor

  @idobata_event_manager Eloido.Idobata.EventManager

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(GenEvent, [[name: @idobata_event_manager]]),
      worker(Eloido.Idobata.Connection, [@idobata_event_manager]),
      worker(Eloido.Idobata.Plugins.Logger, [@idobata_event_manager]),
    ]
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end
end
