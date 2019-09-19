defmodule SmokeWeb.MetricsView do
  use SmokeWeb, :view

  def render("list_events.json", data),
    do: Map.take(data, [:event_names])

  def render("list_measurements.json", data),
    do: Map.take(data, [:event_name, :measurements])

  def render("list_metrics.json", data),
    do: Map.take(data, [:event_name, :measurement, :metrics])

  def render("list_precisions.json", data),
    do: Map.take(data, [:event_name, :measurement, :metric_name, :precisions])

  def render("metrics.json", data),
    do: Map.take(data, [:event_name, :measurement, :metrics, :precision, :metric_name])
end
