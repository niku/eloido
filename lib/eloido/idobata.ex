defmodule Eloido.Idobata do
  use Supervisor

  @idobata_event_manager Eloido.Idobata.EventManager

  def start_link(%{} = config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def init(%{} = config) do
    children = [
      worker(GenEvent, [[name: @idobata_event_manager]]),
      worker(Eloido.Idobata.Connection, [Map.put(config, :idobata_event_manager, @idobata_event_manager)]),
      worker(Eloido.Idobata.Plugins.Logger, [@idobata_event_manager]),
    ]
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end
end
