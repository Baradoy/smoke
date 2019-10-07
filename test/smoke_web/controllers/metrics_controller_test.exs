defmodule SmokeWeb.MetricsControllerTest do
  use SmokeWeb.ConnCase

  @event_name [:smoke, :example, :done]

  @metrics [
    :counter,
    :sum,
    :last_value,
    :statistics,
    :distribution,
    :max,
    :mean,
    :median,
    :min,
    :mode,
    :p95,
    :p99,
    :variance
  ]

  setup do
    fire_event()
  end

  describe "GET /" do
    test "Contains the configured metrics in HTML", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Smoke"

      assert html_response(conn, 200) =~ "smoke.example.done"
      assert html_response(conn, 200) =~ "smoke.example.failed"
    end

    test "Contains the configured metrics in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/")

      assert json_response(conn, 200) == %{
               "event_names" => ["smoke.example.done", "smoke.example.failed"]
             }
    end
  end

  describe "GET /events/:event_name" do
    test "Contains the Measurements in html", %{conn: conn} do
      conn = get(conn, "/events/smoke.example.done")
      assert html_response(conn, 200) =~ "Measurements"
      assert html_response(conn, 200) =~ "latency"
    end

    test "Contains the Measurements in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/events/smoke.example.done")

      assert json_response(conn, 200) == %{
               "event_name" => "smoke.example.done",
               "measurements" => ["latency"]
             }
    end
  end

  describe "GET /events/:event_name/:measurement" do
    test "Lists available metrics in html", %{conn: conn} do
      conn = get(conn, "/events/smoke.example.done/latency")
      assert html_response(conn, 200) =~ "Metrics"
      assert html_response(conn, 200) =~ "latency"
    end

    test "Lists available metrics in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/events/smoke.example.done/latency")

      assert json_response(conn, 200) == %{
               "event_name" => "smoke.example.done",
               "measurement" => "latency",
               "metrics" => [
                 "counter",
                 "sum",
                 "last_value",
                 "statistics",
                 "distribution",
                 "max",
                 "mean",
                 "median",
                 "min",
                 "mode",
                 "p95",
                 "p99",
                 "variance"
               ]
             }
    end
  end

  describe "GET /events/:event_name/:measurement/:metric_name" do
    test "Lists available precisions in html", %{conn: conn} do
      conn = get(conn, "/events/smoke.example.done/latency/sum")
      assert html_response(conn, 200) =~ "Metrics"
      assert html_response(conn, 200) =~ "latency"
      assert html_response(conn, 200) =~ "smoke.example.done"
      assert html_response(conn, 200) =~ "hour"
    end

    test "Lists available precisions in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/events/smoke.example.done/latency/sum")

      assert json_response(conn, 200) == %{
               "event_name" => "smoke.example.done",
               "measurement" => "latency",
               "metric_name" => "sum",
               "precisions" => ["month", "day", "hour", "minute", "second"]
             }
    end
  end

  describe "/events/:event_name/:measurement/:metric_name/:percision" do
    test "metrics in JSON" do
      @metrics
      |> Enum.each(fn metric ->
        metric_string = Atom.to_string(metric)

        conn =
          build_conn()
          |> put_req_header("accept", "application/json")
          |> get("/events/smoke.example.done/latency/#{metric_string}/hour")

        assert %{
                 "event_name" => "smoke.example.done",
                 "measurement" => "latency",
                 "metric_name" => ^metric_string,
                 "precision" => "hour",
                 "metrics" => [
                   %{"metric" => _, "time" => _}
                 ]
               } = json_response(conn, 200)
      end)
    end

    test "metrics in html" do
      @metrics
      |> Enum.each(fn metric ->
        metric_string = Atom.to_string(metric)
        conn = get(build_conn(), "/events/smoke.example.done/latency/#{metric_string}/hour")
        assert html_response(conn, 200) =~ metric_string
        assert html_response(conn, 200) =~ "latency"
      end)
    end
  end

  describe "/events/:event_name/:measurement/statistics/:percision" do
    test "statistics in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/events/smoke.example.done/latency/statistics/hour")

      assert %{
               "event_name" => "smoke.example.done",
               "measurement" => "latency",
               "precision" => "hour",
               "metric_name" => "statistics",
               "metrics" => [
                 %{
                   "time" => _,
                   "metric" => %{
                     "max" => _,
                     "mean" => _,
                     "median" => _,
                     "min" => _,
                     "mode" => _,
                     "p95" => _,
                     "p99" => _,
                     "variance" => _
                   }
                 }
               ]
             } = json_response(conn, 200)
    end
  end

  describe "/events/:event_name/:measurement/distribution" do
    test "distribution in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/events/smoke.example.done/latency/distribution/hour")

      assert %{
               "event_name" => "smoke.example.done",
               "measurement" => "latency",
               "metric_name" => "distribution",
               "precision" => "hour",
               "metrics" => [
                 %{"metric" => %{"292" => _}, "time" => _}
               ]
             } = json_response(conn, 200)
    end
  end

  defp fire_event(value \\ 292) do
    :ok =
      :telemetry.execute(
        @event_name,
        %{latency: value},
        %{request_path: inspect(self()), status_code: 404, more: "data"}
      )
  end
end
