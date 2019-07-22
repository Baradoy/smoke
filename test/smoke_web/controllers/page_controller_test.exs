defmodule SmokeWeb.SmokeControllerTest do
  use SmokeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Smoke"

    # Contains the configured metrics
    assert html_response(conn, 200) =~ "smoke.example.done"
    assert html_response(conn, 200) =~ "smoke.example.failed"
  end
end
