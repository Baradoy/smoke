defmodule Smoke.Application do
  @moduledoc """
  Handles starting supervisors and workers for the Smoke Application
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    instrument = Application.get_env(:smoke, :instrument, [])
    standalone_endpoint = Application.get_env(:smoke, :standalone_endpoint, false)

    children = [
      %{
        id: Smoke.Server,
        start: {Smoke.Server, :start_link, [instrument]}
      }
    ]

    children =
      if standalone_endpoint do
        children ++ [supervisor(SmokeWeb.Endpoint, [])]
      else
        children
      end

    opts = [strategy: :one_for_one, name: Smoke.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SmokeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
