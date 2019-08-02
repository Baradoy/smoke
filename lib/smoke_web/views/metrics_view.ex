defmodule SmokeWeb.MetricsView do
  use SmokeWeb, :view

  def render("index.json", %{event_names: event_names}),
    do: %{event_names: event_names}

  def render("measurements.json", %{event_name: event_name, measurements: measurements}),
    do: %{event_name: event_name, measurements: measurements}

  def render("metrics.json", %{event_name: event_name, measurement: measurement, metrics: metrics}),
      do: %{event_name: event_name, measurement: measurement, metrics: metrics}

  def render("counter.json", %{event_name: event_name, measurement: measurement, counter: counter}),
      do: %{event_name: event_name, measurement: measurement, counter: counter}

  def render("sum.json", %{event_name: event_name, measurement: measurement, sum: sum}),
    do: %{event_name: event_name, measurement: measurement, sum: sum}

  def render("last_value.json", %{
        event_name: event_name,
        measurement: measurement,
        last_value: last_value
      }),
      do: %{event_name: event_name, measurement: measurement, last_value: last_value}

  def render("statistics.json", %{
        event_name: event_name,
        measurement: measurement,
        statistics: statistics
      }),
      do: %{event_name: event_name, measurement: measurement, statistics: statistics}

  def render("distribution.json", %{
        event_name: event_name,
        measurement: measurement,
        histogram: histogram
      }),
      do: %{event_name: event_name, measurement: measurement, histogram: histogram}
end
