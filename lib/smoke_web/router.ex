defmodule SmokeWeb.Router do
  use SmokeWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
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
    get("/events/:event_name/:measurement/counter", MetricsController, :counter)
    get("/events/:event_name/:measurement/sum", MetricsController, :sum)
    get("/events/:event_name/:measurement/last_value", MetricsController, :last_value)
    get("/events/:event_name/:measurement/statistics", MetricsController, :statistics)
    get("/events/:event_name/:measurement/distribution", MetricsController, :distribution)
    get("/events/:event_name/:measurement", MetricsController, :metrics)
    get("/events/:event_name", MetricsController, :measurements)
    get("/", MetricsController, :index)
  end
end
