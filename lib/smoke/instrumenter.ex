defmodule Smoke.Instrumenter do
  @moduledoc """
  Handles Telemetry events by passing them to the Smoke.Server
  """

  alias Smoke.Server

  def handle_event(event, measurements, metadata, config) do
    case Keyword.get(config || [], :smoke_server_pid) do
      pid when is_pid(pid) ->
        Server.add_event(event, measurements, metadata, config, pid)

      _ ->
        Server.add_event(event, measurements, metadata, config)
    end
  end
end
