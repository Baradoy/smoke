defmodule Smoke do
  @moduledoc """
  Future API pieces will go here.

  For the moment, sample events go here.
  """
  alias Smoke.Server

  def list_event_names() do
    Server.list_event_names()
  end

  def get_events(event_name) do
    Server.get_events(event_name)
  end

  def fire_example do
    :telemetry.execute(
      [:smoke, :example, :done],
      %{latency: 292},
      %{request_path: inspect(self()), status_code: 404, more: "data"}
    )
  end

  def fire_example2 do
    :telemetry.execute(
      [:smoke, :example, :done],
      %{latency: 1, larceny: 20},
      %{request_path: inspect(self()), status_code: 404, more: "things", tag: :other}
    )
  end

  def fire_example3 do
    :telemetry.execute(
      [:smoke, :example, :done],
      %{latency: 7, larceny: 21},
      %{request_path: inspect(self()), status_code: 404, more: "beyond", tag: :other}
    )
  end
end
