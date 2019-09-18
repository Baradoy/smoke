defmodule Smoke.EventAgentTest do
  use ExUnit.Case

  alias Smoke.EventAgent
  alias Smoke.Server.Config

  @limit 20
  @clawback 5
  @event %{some: :event}

  setup do
    {:ok, pid} = EventAgent.start_link(%Config{max_events: @limit, clawback: @clawback})

    {:ok, agent: pid}
  end

  describe "get_events/1" do
    test "gets an empty list", %{agent: pid} do
      assert EventAgent.get_events(pid) == []
    end

    test "gets a list of one event", %{agent: pid} do
      insert_event(pid)

      assert EventAgent.get_events(pid) |> length() == 1
    end
  end

  describe "add_event/4" do
    test "adding events up to the limit does not loose any events", %{agent: pid} do
      1..@limit |> Enum.each(fn _ -> EventAgent.add_event(pid, @event) end)

      assert EventAgent.get_events(pid) |> length() == @limit
    end

    test "adding events over the limit multiple times keeps within the limit", %{agent: pid} do
      1..(@limit * 5 - 1) |> Enum.each(fn _ -> EventAgent.add_event(pid, @event) end)

      assert EventAgent.get_events(pid) |> length() == @limit - 1
    end
  end

  defp insert_event(pid) do
    EventAgent.add_event(pid, %{some: :event})
  end
end
