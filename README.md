# Smoke

Smoke provides easy access [:telemetry](https://github.com/beam-telemetry/telemetry) metrics for your application.

The metrics provided by Smoke attempt to be "Good enough, for now, I guess". 

## How it works

The :telemetry events for Smoke are stored in memory. To avoid running out of memory Smoke caps the number of messages that it keeps (defaulting to 1000 per event type). 

## When Should I Use Smoke? 

Smoke is useful in two cases: 

- You are early days in your project and you would like some limited visibility into your telemetry events without having to wrangle an external service. 
- You have severe limitations on infrastructure and cannot ship your metrics to an external service. 

## When Should I Not Use Smoke? 

Don't use Smoke if you have the time and ability to send your events to an external service. 

## Installation

Once this gets published to Hex, you will be able to install it with the following:

```elixir
def deps do
  [
    {:smoke, github: "Baradoy/smoke"}
  ]
end
```

## Configuration 

Configure `Smoke` to watch `:telemetry` events:

```elixir
config :smoke,
  instrument: [
    [:smoke, :example, :done], 
    [:smoke, :example, :failed]
  ]
```

## Web interface

### In a Phoenix Project

If you already have Phoenix running, you can enable the web interface by adding the following to your projects router file: 

```elixir
defmodule MyProjectWeb.Router do
  use MyProjectWeb, :router

  # Your routes here
  # ...

  scope "/smoke", SmokeWeb do
    forward("/", Router, namespace: "smoke")
  end
end
```

You can now find your metrics at `http://yourendpoint.com/smoke`

### As a Phoenix Server

If you do not have Phoenix running, you can configure `Smoke` to run its own Phoenix server

```elixir
config :smoke,  
  standalone_endpoint: true

config :smoke, SmokeWeb.Endpoint,
  url: [host: "localhost", port: 4000],
  render_errors: [view: SmokeWeb.ErrorView, accepts: ~w(html json)]
```

You can now find your metrics at http://localhost:4000/
