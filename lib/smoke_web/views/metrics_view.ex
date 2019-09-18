defmodule SmokeWeb.MetricsView do
  use SmokeWeb, :view

  def render("index.json", %{event_names: event_names}),
    do: %{event_names: event_names}

  def render("measurements.json", %{event_name: event_name, measurements: measurements}),
    do: %{event_name: event_name, measurements: measurements}

  def render("metrics.json", %{event_name: event_name, measurement: measurement, metrics: metrics}),
      do: %{event_name: event_name, measurement: measurement, metrics: metrics}

  def render("counter.json", data),
    do: Map.take(data, [:event_name, :measurement, :counter, :first_event_time])

  def render("sum.json", data),
    do: Map.take(data, [:event_name, :measurement, :sum, :first_event_time])

  def render("last_value.json", data),
    do: Map.take(data, [:event_name, :measurement, :last_value, :first_event_time])

  def render("statistics.json", data),
    do: Map.take(data, [:event_name, :measurement, :statistics, :first_event_time])

  def render("distribution.json", data),
    do: Map.take(data, [:event_name, :measurement, :histogram, :first_event_time])
end
