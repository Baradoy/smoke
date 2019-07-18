# Smoke

Smoke provides easy instrumentation to access [:telemetry](https://github.com/beam-telemetry/telemetry) metrics for your application. 

Smoke is designed as a stepping stone towards properly instrumenting your application. 

Smoke give sufficient enough, I guess, metrics


## Installation

Once this gets published to Hex, you will be able to install it with the following:

```elixir
def deps do
  [
    {:smoke, "~> 0.1.0"}
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

If you do not have Phoenix running, you can configure `Smoke` to run its own Phoenix server

```elixir
config :smoke,  
  standalone_endpoint: true

config :smoke, SmokeWeb.Endpoint,
  url: [host: "localhost", port: 4000],
  render_errors: [view: SmokeWeb.ErrorView, accepts: ~w(html json)]
```


