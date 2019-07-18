defmodule Smoke.Metrics do
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

  def last_value(events, key) do
    get_measure = measurement_value(key)

    events
    |> Enum.map(get_measure)
    |> Enum.reduce(nil, fn
      event, acc when is_nil(event) -> acc
      event, _acc -> event
    end)
  end

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

  defp measurement_value(key, default \\ nil) do
    fn {_time, measurement, _metadata} ->
      Map.get(measurement, key, default)
    end
  end
end
