defmodule SmokeWeb.MetricsController do
  use SmokeWeb, :controller

  alias Smoke.Server
  alias Smoke.Metrics

  def index(conn, _params) do
    # events = Smoke.Server.get_events([:smoke, :example, :done])
    event_names =
      Smoke.Server.list_event_names()
      |> Enum.map(&path_to_strings/1)

    render(conn, "index.html", event_names: event_names)
  end

  def measurements(conn, %{"event_name" => event_name}) do
    measurements =
      event_name
      |> string_to_path()
      |> Smoke.Server.get_events()
      |> Metrics.measurements()
      |> Enum.map(&Atom.to_string/1)

    render(conn, "measurements.html", event_name: event_name, measurements: measurements)
  end

  def metrics(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    metrics = [:counter, :sum, :last_value, :statistics, :distribution]

    render(conn, "metrics.html",
      event_name: event_name,
      measurement: measurement,
      metrics: metrics
    )
  end

  def counter(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    measurement = String.to_atom(measurement)

    counter =
      event_name
      |> string_to_path()
      |> Server.get_events()
      |> Metrics.counter(measurement)

    render(conn, "counter.html",
      event_name: event_name,
      measurement: measurement,
      counter: counter
    )
  end

  def sum(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    measurement = String.to_atom(measurement)

    sum =
      event_name
      |> string_to_path()
      |> Server.get_events()
      |> Metrics.sum(measurement)

    render(conn, "sum.html",
      event_name: event_name,
      measurement: measurement,
      sum: sum
    )
  end

  def last_value(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    measurement = String.to_atom(measurement)

    last_value =
      event_name
      |> string_to_path()
      |> Server.get_events()
      |> Metrics.last_value(measurement)

    render(conn, "last_value.html",
      event_name: event_name,
      measurement: measurement,
      last_value: last_value
    )
  end

  def statistics(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    measurement = String.to_atom(measurement)

    statistics =
      event_name
      |> string_to_path()
      |> Server.get_events()
      |> Metrics.statistics(measurement)

    render(conn, "statistics.html",
      event_name: event_name,
      measurement: measurement,
      statistics: statistics
    )
  end

  def distribution(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    measurement = String.to_atom(measurement)

    histogram =
      event_name
      |> string_to_path()
      |> Server.get_events()
      |> Metrics.distribution(measurement)

    render(conn, "distribution.html",
      event_name: event_name,
      measurement: measurement,
      histogram: histogram
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
