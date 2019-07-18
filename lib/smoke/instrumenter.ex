defmodule Smoke.Instrumenter do
  alias Smoke.Server

  def handle_event([:smoke, :example, :done] = event, measurements, metadata, config) do
    Server.add_event(event, measurements, metadata, config)
  end
end
