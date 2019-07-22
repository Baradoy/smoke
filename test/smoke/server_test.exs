defmodule Smoke.ServerTest do
  use ExUnit.Case

  alias Smoke.Server

  @limit 20
  @clawback 5

  @instrument [{[:smoke, :example, :done], @limit, @clawback}, [:smoke, :example, :failed]]

  @event_name [:smoke, :example, :done]

  setup do
    {:ok, server_pid} = Server.start_link(@instrument, __MODULE__)

    on_exit(fn ->
      Enum.each(@instrument, fn event_name ->
        Server.detach(event_name, __MODULE__)
      end)
    end)

    {:ok, server: server_pid}
  end

  describe "get_events/1" do
    test "gets an empty list", %{server: pid} do
      assert Server.get_events(@event_name, pid) == []
    end

    test "gets a list of one event", %{server: pid} do
      fire_event()

      assert @event_name |> Server.get_events(pid) |> length() == 1
    end

    test "gets an empty list when another type of events have fired", %{server: pid} do
      fire_event()

      assert [:smoke, :example, :failed] |> Server.get_events(pid) == []
    end
  end

  describe "add_event/4" do
    test "firing events up to the limit does not loose any events", %{server: pid} do
      1..@limit |> Enum.each(fn _ -> fire_event() end)

      assert @event_name |> Server.get_events(pid) |> length() == @limit
    end

    test "Firing over the limit multiple times keeps within the limit", %{server: pid} do
      1..(@limit * 5 - 1) |> Enum.each(fn _ -> fire_event() end)

      assert @event_name |> Server.get_events(pid) |> length() == @limit - 1
    end

    test "firing events just over the limit removes events", %{server: pid} do
      1..(@limit + 1) |> Enum.each(fn _ -> fire_event() end)

      assert @event_name |> Server.get_events(pid) |> length() == @limit - @clawback + 1
    end

    test "firing events over the limit keeps the most recent events", %{server: pid} do
      1..(@limit + 1) |> Enum.each(fn x -> fire_event(x) end)

      assert @event_name
             |> Server.get_events(pid)
             |> Enum.map(fn {_, %{latency: latency}, _} -> latency end) ==
               (@clawback + 1)..(@limit + 1) |> Enum.reverse()
    end
  end

  defp fire_event(value \\ 292) do
    :ok =
      :telemetry.execute(
        @event_name,
        %{latency: value},
        %{request_path: inspect(self()), status_code: 404, more: "data"}
      )
  end
end
