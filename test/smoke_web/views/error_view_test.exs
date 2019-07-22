defmodule SmokeWeb.ErrorViewTest do
  use SmokeWeb.ConnCase, async: true

  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(SmokeWeb.ErrorView, "404.html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(SmokeWeb.ErrorView, "500.html", []) == "Internal Server Error"
  end
end
