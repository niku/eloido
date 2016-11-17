defmodule Eloido.Idobata.Plugins.Logger do
  @moduledoc """
  A logger plugin for eloido.
  """

  require Logger

  def start_link(idobata_event_manager) do
    Task.start_link(fn ->
      for message <- GenEvent.stream(idobata_event_manager) do
        Logger.debug((inspect message))
      end
    end)
  end
end
