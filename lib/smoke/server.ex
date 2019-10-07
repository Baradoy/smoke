defmodule Smoke.Server do
  @moduledoc """
  Handles storage of events.

  Enforces the cap on the number of events of a particular type.
  """
  use GenServer

  require Logger

  alias Smoke.Instrumenter
  alias Smoke.EventAgent

  defmodule Config do
    @moduledoc """
    Configuration for maximum number of events to hold and the number of events to drop when the limit is reached.
    """
    defstruct max_events: 1000, clawback: 100
  end

  # API

  def start_link(event_names, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, %{event_names: event_names, server_name: name}, name: name)
  end

  def get_events(event_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:get_events, event_name})
  end

  def list_event_names(pid \\ __MODULE__) do
    GenServer.call(pid, :list_event_names)
  end

  def add_event(
        event,
        measurements,
        metadata,
        _config,
        pid \\ __MODULE__
      ) do
    GenServer.cast(pid, {:add_event, event, DateTime.utc_now(), measurements, metadata})
  end

  # Callbacks

  @impl true
  def init(%{event_names: event_names, server_name: server_name}) do
    Enum.each(event_names, fn event_name -> attach(event_name, server_name) end)

    agents =
      Enum.into(event_names, %{}, fn
        {event_name, max_events, clawback} ->
          {:ok, pid} = EventAgent.start_link(%Config{max_events: max_events, clawback: clawback})
          {event_name, pid}

        event_name ->
          {:ok, pid} = EventAgent.start_link(%Config{})
          {event_name, pid}
      end)

    {:ok, %{agents: agents}}
  end

  @impl true
  def handle_call({:get_events, event_name}, _from, %{agents: agents} = state) do
    events =
      agents
      |> Map.get(event_name)
      |> EventAgent.get_events()

    {:reply, events, state}
  end

  def handle_call(:list_event_names, _from, state) do
    event_names = state |> Map.fetch!(:agents) |> Map.keys()
    {:reply, event_names, state}
  end

  @impl true
  def handle_cast(
        {:add_event, event_name, date_time, measurements, metadata},
        %{agents: agents} = state
      ) do
    agents
    |> Map.get(event_name)
    |> EventAgent.add_event({date_time, measurements, metadata})

    {:noreply, state}
  end

  # Private

  defp attach({event_name, _, _}, server_name), do: attach(event_name, server_name)

  defp attach(event_name, server_name) do
    :ok =
      :telemetry.attach(
        handler_id(event_name, server_name),
        event_name,
        &Instrumenter.handle_event/4,
        smoke_server_pid: self()
      )
  end

  def detach({event_name, _, _}, server_name), do: detach(event_name, server_name)

  def detach(event_name, server_name) do
    :telemetry.detach(handler_id(event_name, server_name))
  end

  defp handler_id(event_name, server_name) do
    "smoke-#{server_name}." <> Enum.join(event_name, ".")
  end
end
