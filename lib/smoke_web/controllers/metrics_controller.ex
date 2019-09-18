defmodule SmokeWeb.MetricsController do
  use SmokeWeb, :controller

  alias Smoke.Server
  alias Smoke.Metrics

  def index(conn, _params) do
    # events = Smoke.Server.get_events([:smoke, :example, :done])
    event_names =
      Smoke.Server.list_event_names()
      |> Enum.map(&path_to_strings/1)

    render(conn, event_names: event_names)
  end

  def measurements(conn, %{"event_name" => event_name}) do
    measurements =
      event_name
      |> string_to_path()
      |> Smoke.Server.get_events()
      |> Metrics.measurements()
      |> Enum.map(&Atom.to_string/1)

    render(conn, event_name: event_name, measurements: measurements)
  end

  def metrics(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    metrics = [:counter, :sum, :last_value, :statistics, :distribution]

    render(conn,
      event_name: event_name,
      measurement: measurement,
      metrics: metrics
    )
  end

  def counter(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    measurement = String.to_atom(measurement)

    events =
      event_name
      |> string_to_path()
      |> Server.get_events()

    counter = Metrics.counter(events, measurement)

    render(conn,
      event_name: event_name,
      measurement: measurement,
      counter: counter,
      first_event_time: Metrics.first_event_time(events)
    )
  end

  def sum(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    measurement = String.to_atom(measurement)

    events =
      event_name
      |> string_to_path()
      |> Server.get_events()

    sum = Metrics.sum(events, measurement)

    render(conn,
      event_name: event_name,
      measurement: measurement,
      sum: sum,
      first_event_time: Metrics.first_event_time(events)
    )
  end

  def last_value(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    measurement = String.to_atom(measurement)

    events =
      event_name
      |> string_to_path()
      |> Server.get_events()

    last_value = Metrics.last_value(events, measurement)

    render(conn,
      event_name: event_name,
      measurement: measurement,
      last_value: last_value,
      first_event_time: Metrics.first_event_time(events)
    )
  end

  def statistics(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    measurement = String.to_atom(measurement)

    events =
      event_name
      |> string_to_path()
      |> Server.get_events()

    statistics = Metrics.statistics(events, measurement)

    render(conn,
      event_name: event_name,
      measurement: measurement,
      statistics: statistics,
      first_event_time: Metrics.first_event_time(events)
    )
  end

  def distribution(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    measurement = String.to_atom(measurement)

    events =
      event_name
      |> string_to_path()
      |> Server.get_events()

    histogram = Metrics.distribution(events, measurement)

    render(conn,
      event_name: event_name,
      measurement: measurement,
      histogram: histogram,
      first_event_time: Metrics.first_event_time(events)
    )
  end

  defp path_to_strings(path) do
    Enum.join(path, ".")
  end

  defp string_to_path(names) do
    names
    |> String.split(".")
    |> Enum.map(&String.to_existing_atom/1)
  end
end
