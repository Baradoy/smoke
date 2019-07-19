defmodule Smoke.Server do
  @moduledoc """
  Handles storage of events.

  Enforces the cap on the number of events of a particular type.
  """
  use GenServer

  require Logger

  alias Smoke.Instrumenter

  defmodule Config do
    @moduledoc """
    Configuration for maximum number of events to hold and the number of events to drop when the limit is reached.
    """
    defstruct max_events: 1000, clawback: 100
  end

  # API

  def start_link(event_names, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, %{event_names: event_names}, name: name)
  end

  def get_events(event_name, pid \\ __MODULE__) do
    GenServer.call(pid, {:get_events, event_name})
  end

  def list_event_names(pid \\ __MODULE__) do
    GenServer.call(pid, :list_event_names)
  end

  def add_event(
        [:smoke, :example, :done] = event,
        measurements,
        metadata,
        _config,
        pid \\ __MODULE__
      ) do
    GenServer.cast(pid, {event, DateTime.utc_now(), measurements, metadata})
  end

  # Callbacks

  @impl true
  def init(%{event_names: event_names}) do
    events =
      event_names
      |> Enum.map(&attach/1)
      |> Enum.map(fn
        {event_name, max_events, clawback} ->
          {event_name, %{events: [], config: %Config{max_events: max_events, clawback: clawback}}}

        event_name ->
          {event_name, %{events: [], config: %Config{}}}
      end)
      |> Enum.into(%{})

    {:ok, %{events: events, config: %Config{}}}
  end

  @impl true
  def handle_call({:get_events, event_name}, _from, state) do
    events = get_in(state, events_path(event_name))
    {:reply, events, state}
  end

  def handle_call(:list_event_names, _from, state) do
    event_names = state |> Map.fetch!(:events) |> Map.keys()
    {:reply, event_names, state}
  end

  @impl true
  def handle_cast({event_name, date_time, measurements, metadata}, state) do
    new_state =
      update_in(state, events_path(event_name), fn events_list ->
        add_event({date_time, measurements, metadata}, events_list, config(event_name, state))
      end)

    {:noreply, new_state}
  end

  # Private

  defp add_event(event, events_list, %Config{max_events: max_events})
       when length(events_list) < max_events do
    [event | events_list]
  end

  defp add_event(event, events_list, %Config{clawback: clawback} = config) do
    shortened_events_list = Enum.drop(events_list, -clawback)
    add_event(event, shortened_events_list, config)
  end

  defp events_path(event_name) do
    [:events, event_name, :events]
  end

  defp config(event_name, state) do
    get_in(state, [:events, event_name, :config])
  end

  defp attach({event_name, _, _} = arg) do
    attach(event_name)
    arg
  end

  defp attach(event_name) do
    :ok =
      :telemetry.attach(
        "smoke-instrumenter-" <> Enum.join(event_name, "."),
        event_name,
        &Instrumenter.handle_event/4,
        nil
      )

    event_name
  end
end
