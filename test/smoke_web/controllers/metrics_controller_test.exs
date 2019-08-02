defmodule SmokeWeb.MetricsControllerTest do
  use SmokeWeb.ConnCase

  @event_name [:smoke, :example, :done]

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
               "metrics" => ["counter", "sum", "last_value", "statistics", "distribution"]
             }
    end
  end

  describe "/events/:event_name/:measurement/counter" do
    test "counter in html", %{conn: conn} do
      conn = get(conn, "/events/smoke.example.done/latency/counter")
      assert html_response(conn, 200) =~ "Counter"
      assert html_response(conn, 200) =~ "latency"
    end

    test "counter in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/events/smoke.example.done/latency/counter")

      assert %{
               "event_name" => "smoke.example.done",
               "counter" => _,
               "measurement" => "latency"
             } = json_response(conn, 200)
    end
  end

  describe "/events/:event_name/:measurement/sum" do
    test "sum in html", %{conn: conn} do
      conn = get(conn, "/events/smoke.example.done/latency/sum")
      assert html_response(conn, 200) =~ "Sum"
      assert html_response(conn, 200) =~ "latency"
    end

    test "sum in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/events/smoke.example.done/latency/sum")

      assert %{
               "event_name" => "smoke.example.done",
               "sum" => _,
               "measurement" => "latency"
             } = json_response(conn, 200)
    end
  end

  describe "/events/:event_name/:measurement/last_value" do
    test "last_value in html", %{conn: conn} do
      conn = get(conn, "/events/smoke.example.done/latency/last_value")
      assert html_response(conn, 200) =~ "Last Value"
      assert html_response(conn, 200) =~ "latency"
    end

    test "last_value in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/events/smoke.example.done/latency/last_value")

      assert %{
               "event_name" => "smoke.example.done",
               "last_value" => _,
               "measurement" => "latency"
             } = json_response(conn, 200)
    end
  end

  describe "/events/:event_name/:measurement/statistics" do
    test "statistics in html", %{conn: conn} do
      conn = get(conn, "/events/smoke.example.done/latency/statistics")
      assert html_response(conn, 200) =~ "Statistics"
      assert html_response(conn, 200) =~ "latency"
    end

    test "statistics in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/events/smoke.example.done/latency/statistics")

      assert %{
               "event_name" => "smoke.example.done",
               "statistics" => %{
                 "max" => _,
                 "mean" => _,
                 "median" => _,
                 "min" => _,
                 "mode" => _,
                 "p95" => _,
                 "p99" => _,
                 "variance" => _
               },
               "measurement" => "latency"
             } = json_response(conn, 200)
    end
  end

  describe "/events/:event_name/:measurement/distribution" do
    test "distribution in html", %{conn: conn} do
      conn = get(conn, "/events/smoke.example.done/latency/distribution")
      assert html_response(conn, 200) =~ "Distribution"
      assert html_response(conn, 200) =~ "latency"
    end

    test "distribution in JSON", %{conn: conn} do
      conn =
        conn
        |> put_req_header("accept", "application/json")
        |> get("/events/smoke.example.done/latency/distribution")

      assert %{
               "event_name" => "smoke.example.done",
               "histogram" => %{"292" => _},
               "measurement" => "latency"
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
