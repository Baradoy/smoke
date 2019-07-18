# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :smoke, SmokeWeb.Endpoint,
  url: [host: "localhost"],
  # secret_key_base: "9n5leDT63ohlOyd/PJCBpV+nZlHWjDJpuLZUqHjoOTKJszHmVNn22QkB44aop9XH",
  render_errors: [view: SmokeWeb.ErrorView, accepts: ~w(html json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
