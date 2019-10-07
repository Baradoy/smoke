defmodule SmokeWeb.Router do
  use SmokeWeb, :router

  pipeline :browser do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", SmokeWeb do
    pipe_through(:browser)
    get("/events/:event_name/:measurement/:metric_name/:precision", MetricsController, :metrics)
    get("/events/:event_name/:measurement/:metric_name", MetricsController, :list_precisions)
    get("/events/:event_name/:measurement", MetricsController, :list_metrics)
    get("/events/:event_name", MetricsController, :list_measurements)
    get("/", MetricsController, :list_events)
  end
end
