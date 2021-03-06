defmodule Smoke.Metrics do
  @moduledoc """
  Creates Metrics from a list of events.
  """

  def filter(events, {tag, value}) do
    events
    |> Stream.filter(fn
      {_time, _measurement, metadata} ->
        Enum.any?(metadata, fn
          {^tag, ^value} -> true
          _ -> false
        end)
    end)
  end

  def filter(events, [head | tail]) do
    events
    |> filter(head)
    |> filter(tail)
  end

  def filter(events, []), do: events

  def time_bucket(events, precision) do
    Stream.chunk_by(events, fn {time, _measurement, _metadata} ->
      truncate(time, precision)
    end)
    |> Stream.map(fn [{time, _measurement, _metadata} | _tail] = events ->
      %{time: truncate(time, precision), events: events}
    end)
  end

  def truncate(date_time, :month), do: %{truncate(date_time, :day) | day: 1}
  def truncate(date_time, :day), do: %{truncate(date_time, :hour) | hour: 0}
  def truncate(date_time, :hour), do: %{truncate(date_time, :minute) | minute: 0}
  def truncate(date_time, :minute), do: %{truncate(date_time, :second) | second: 0}
  def truncate(date_time, precision), do: DateTime.truncate(date_time, precision)

  def tags(events) do
    events
    |> Enum.reduce(MapSet.new(), fn
      {_time, _measurement, metadata}, acc ->
        metadata |> Map.keys() |> Enum.into(acc)
    end)
    |> MapSet.to_list()
  end

  def apply_to_bucketed_events(bucketed_events, key, metrics_function) do
    Stream.map(bucketed_events, fn %{time: time, events: events} ->
      %{time: time, metric: metrics_function.(events, key)}
    end)
  end

  def measurements(events) do
    events
    |> Enum.reduce(MapSet.new(), fn
      {_time, measurement, _metadata}, acc ->
        measurement |> Map.keys() |> Enum.into(acc)
    end)
    |> MapSet.to_list()
  end

  def tag_values(events, tag_name) do
    events
    |> Enum.reduce(MapSet.new(), fn
      {_time, _measurement, metadata}, acc ->
        value = Map.get(metadata, tag_name)
        MapSet.put(acc, value)
    end)
    |> MapSet.to_list()
  end

  def counter(events, key) do
    get_measure = measurement_value(key)

    events
    |> Stream.map(get_measure)
    |> Enum.count(fn x -> not is_nil(x) end)
  end

  def sum(events, key) do
    get_measure = measurement_value(key, 0)

    events
    |> Stream.map(get_measure)
    |> Enum.sum()
  end

  def last_value([{_time, measurement, _metadata} = _head | tail], key) do
    if Map.has_key?(measurement, key) do
      Map.get(measurement, key)
    else
      last_value(tail, key)
    end
  end

  def last_value(_events, _key), do: nil

  def statistics(events, key) do
    get_measure = measurement_value(key)

    measurements =
      events
      |> Enum.map(get_measure)
      |> Enum.filter(fn measure -> not is_nil(measure) end)

    %{
      median: Statistics.median(measurements),
      mean: Statistics.mean(measurements),
      max: Statistics.max(measurements),
      min: Statistics.min(measurements),
      mode: Statistics.mode(measurements),
      variance: Statistics.variance(measurements),
      p95: Statistics.percentile(measurements, 95),
      p99: Statistics.percentile(measurements, 99)
    }
  end

  def distribution(events, key) do
    get_measure = measurement_value(key)

    events
    |> Enum.map(get_measure)
    |> Statistics.hist()
  end

  def max(events, key) do
    get_measure = measurement_value(key)

    events
    |> Enum.map(get_measure)
    |> Statistics.max()
  end

  def mean(events, key) do
    get_measure = measurement_value(key)

    events
    |> Enum.map(get_measure)
    |> Statistics.mean()
  end

  def median(events, key) do
    get_measure = measurement_value(key)

    events
    |> Enum.map(get_measure)
    |> Statistics.median()
  end

  def min(events, key) do
    get_measure = measurement_value(key)

    events
    |> Enum.map(get_measure)
    |> Statistics.min()
  end

  def mode(events, key) do
    get_measure = measurement_value(key)

    events
    |> Enum.map(get_measure)
    |> Statistics.mode()
  end

  def p95(events, key) do
    get_measure = measurement_value(key)

    events
    |> Enum.map(get_measure)
    |> Statistics.percentile(95)
  end

  def p99(events, key) do
    get_measure = measurement_value(key)

    events
    |> Enum.map(get_measure)
    |> Statistics.percentile(99)
  end

  def variance(events, key) do
    get_measure = measurement_value(key)

    events
    |> Enum.map(get_measure)
    |> Statistics.variance()
  end

  def first_event_time([]), do: nil

  def first_event_time(events) do
    events |> List.last() |> elem(0)
  end

  defp measurement_value(key, default \\ nil) do
    fn {_time, measurement, _metadata} ->
      Map.get(measurement, key, default)
    end
  end
end
