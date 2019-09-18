defmodule Smoke.EventAgent do
  @moduledoc """
  Keeps track of a list of events. Discard old events when `max_events` is reached.
  """

  use Agent

  def start_link(config) do
    Agent.start_link(fn -> %{config: config, events: []} end)
  end

  def add_event(agent, event) do
    Agent.update(agent, fn
      %{events: events, config: %{max_events: max_events}} = state
      when length(events) < max_events ->
        %{state | events: [event | events]}

      %{events: events, config: %{clawback: clawback}} = state ->
        shortened_events = Enum.drop(events, -clawback)
        %{state | events: [event | shortened_events]}
    end)
  end

  def get_events(agent) do
    Agent.get(agent, fn %{events: events} -> events end)
  end
end
