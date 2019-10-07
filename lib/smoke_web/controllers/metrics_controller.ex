defmodule SmokeWeb.MetricsController do
  use SmokeWeb, :controller

  alias Smoke.Server
  alias Smoke.Metrics

  @metrics [
    :counter,
    :sum,
    :last_value,
    :statistics,
    :distribution,
    :max,
    :mean,
    :median,
    :min,
    :mode,
    :p95,
    :p99,
    :variance
  ]

  def list_events(conn, _params) do
    event_names =
      Smoke.Server.list_event_names()
      |> Enum.map(&path_to_strings/1)

    render(conn, event_names: event_names)
  end

  def list_measurements(conn, %{"event_name" => event_name}) do
    measurements =
      event_name
      |> string_to_path()
      |> Smoke.Server.get_events()
      |> Metrics.measurements()
      |> Enum.map(&Atom.to_string/1)

    render(conn, event_name: event_name, measurements: measurements)
  end

  def list_metrics(conn, %{"event_name" => event_name, "measurement" => measurement}) do
    render(conn,
      event_name: event_name,
      measurement: measurement,
      metrics: @metrics
    )
  end

  def list_precisions(conn, %{
        "event_name" => event_name,
        "measurement" => measurement,
        "metric_name" => metric_name
      }) do
    precisions = [:month, :day, :hour, :minute, :second]

    render(conn,
      event_name: event_name,
      measurement: measurement,
      metric_name: metric_name,
      precisions: precisions
    )
  end

  def metrics(conn, %{
        "event_name" => event_name,
        "measurement" => measurement,
        "metric_name" => metric_name,
        "precision" => precision
      }) do
    measurement = String.to_existing_atom(measurement)
    precision = String.to_existing_atom(precision)
    metric_func = metric_function_from_name(metric_name)

    metrics =
      event_name
      |> string_to_path()
      |> Server.get_events()
      |> Metrics.time_bucket(precision)
      |> Metrics.apply_to_bucketed_events(measurement, metric_func)
      |> Enum.map(& &1)

    render(conn,
      metric_name: metric_name,
      event_name: event_name,
      measurement: measurement,
      precision: precision,
      metrics: metrics
    )
  end

  defp metric_function_from_name("counter"), do: &Metrics.counter/2
  defp metric_function_from_name("sum"), do: &Metrics.sum/2
  defp metric_function_from_name("last_value"), do: &Metrics.last_value/2
  defp metric_function_from_name("statistics"), do: &Metrics.statistics/2
  defp metric_function_from_name("distribution"), do: &Metrics.distribution/2
  defp metric_function_from_name("max"), do: &Metrics.max/2
  defp metric_function_from_name("mean"), do: &Metrics.mean/2
  defp metric_function_from_name("median"), do: &Metrics.median/2
  defp metric_function_from_name("min"), do: &Metrics.min/2
  defp metric_function_from_name("mode"), do: &Metrics.mode/2
  defp metric_function_from_name("p95"), do: &Metrics.p95/2
  defp metric_function_from_name("p99"), do: &Metrics.p99/2
  defp metric_function_from_name("variance"), do: &Metrics.variance/2

  defp path_to_strings(path) do
    Enum.join(path, ".")
  end

  defp string_to_path(names) do
    names
    |> String.split(".")
    |> Enum.map(&String.to_existing_atom/1)
  end
end
