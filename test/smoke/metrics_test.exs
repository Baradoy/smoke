defmodule Smoke.MetricsTest do
  use ExUnit.Case

  alias Smoke.Metrics

  describe "filter/2" do
    test "filters for matching tags" do
      events = [
        create_event(%{value: 1}, %{tag: "in"}),
        create_event(%{value: 2}, %{tag: "out"}),
        create_event(%{value: 3}, %{tag: "out"}),
        create_event(%{value: 4}, %{tag: "in"})
      ]

      assert events |> Metrics.filter({:tag, "in"}) |> measurement_value() == [1, 4]
    end

    test "filters for list of matching tags" do
      events = [
        create_event(%{value: 1}, %{tag: "in", other: "in"}),
        create_event(%{value: 2}, %{tag: "out", other: "in"}),
        create_event(%{value: 3}, %{tag: "out", other: "out"}),
        create_event(%{value: 4}, %{tag: "in", other: "out"})
      ]

      assert events
             |> Metrics.filter([{:tag, "in"}, {:other, "in"}])
             |> measurement_value() == [1]
    end
  end

  describe "tags/1" do
    test "lists the tags keys" do
      events = [
        create_event(%{value: 1}, %{tag1: "tag"}),
        create_event(%{value: 2}, %{tag1: "tag"}),
        create_event(%{value: 3}, %{tag2: "tag"}),
        create_event(%{value: 4}, %{tag1: "tag", tag3: "tag"})
      ]

      assert events |> Metrics.tags() == [:tag1, :tag2, :tag3]
    end
  end

  describe "measurements/1" do
    test "lists the measurement keys" do
      events = [
        create_event(%{first_value: 1}),
        create_event(%{value: 2}),
        create_event(%{value: 3}),
        create_event(%{value: 4, other_value: 5})
      ]

      assert events |> Metrics.measurements() == [:first_value, :other_value, :value]
    end
  end

  describe "tag_values/2" do
    test "lists values of a tag" do
      events = [
        create_event(%{value: 1}, %{tag: "tag1"}),
        create_event(%{value: 2}, %{tag: "tag1"}),
        create_event(%{value: 3}, %{tag: "tag2", other_tag: "nope"}),
        create_event(%{value: 4}, %{})
      ]

      assert events |> Metrics.tag_values(:tag) == [nil, "tag1", "tag2"]
    end
  end

  describe "counter/2" do
    test "counts events" do
      events = [
        create_event(%{value: 1}),
        create_event(%{value: 2}),
        create_event(%{value: 3, other_value: 4}),
        create_event(%{other_value: 4})
      ]

      assert events |> Metrics.counter(:value) == 3
    end
  end

  describe "sum/2" do
    test "sums a measurement" do
      events = [
        create_event(%{value: 1}),
        create_event(%{value: 2}),
        create_event(%{value: 3, other_value: 4}),
        create_event(%{other_value: 4})
      ]

      assert events |> Metrics.sum(:value) == 1 + 2 + 3
    end
  end

  describe "last_value/2" do
    test "returns the last value" do
      events = [
        create_event(%{value: 1}),
        create_event(%{value: 2}),
        create_event(%{value: 3, other_value: 4}),
        create_event(%{other_value: 4})
      ]

      assert events |> Metrics.last_value(:value) == 3
    end
  end

  describe "statistics/2" do
    test "returns the mean" do
      events = [
        create_event(%{value: 1}),
        create_event(%{value: 2}),
        create_event(%{value: 3, other_value: 4}),
        create_event(%{other_value: 4})
      ]

      assert events |> Metrics.statistics(:value) |> Map.get(:mean) == 2
    end
  end

  describe "distribution/2" do
    test "creates values for a histogram" do
      events = [
        create_event(%{value: 1}),
        create_event(%{value: 2}),
        create_event(%{value: 3, other_value: 4}),
        create_event(%{value: 3, other_value: 4}),
        create_event(%{other_value: 4})
      ]

      assert events |> Metrics.distribution(:value) == %{3 => 2, 2 => 1, 1 => 1, nil => 1}
    end
  end

  describe "truncate/2" do
    test "month" do
      date = DateTime.utc_now()

      assert %DateTime{
               day: 1,
               hour: 0,
               minute: 0,
               second: 0
             } = Metrics.truncate(date, :month)
    end

    test "day" do
      date = DateTime.utc_now()

      assert %DateTime{
               hour: 0,
               minute: 0,
               second: 0
             } = Metrics.truncate(date, :day)
    end

    test "hour" do
      date = DateTime.utc_now()

      assert %DateTime{
               minute: 0,
               second: 0
             } = Metrics.truncate(date, :day)
    end

    test "minute" do
      date = DateTime.utc_now()

      assert %DateTime{
               second: 0
             } = Metrics.truncate(date, :day)
    end
  end

  defp create_event(measurements, tags \\ %{tag: "default"}) do
    {
      DateTime.utc_now(),
      measurements,
      tags
    }
  end

  defp measurement_value(%Stream{} = events), do: events |> Enum.to_list() |> measurement_value()

  defp measurement_value(events) when is_list(events) do
    Enum.map(events, &measurement_value/1)
  end

  defp measurement_value({_, %{value: measurement}, _}), do: measurement
end
