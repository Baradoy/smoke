defmodule Smoke.Examples do
  @moduledoc """
    Examples to use to get up and running quickly with Smoke
  """

  def fire_example do
    :telemetry.execute(
      [:smoke, :example, :done],
      %{latency: 292},
      %{request_path: inspect(self()), status_code: 404, more: "data"}
    )
  end

  def fire_example2 do
    :telemetry.execute(
      [:smoke, :example, :done],
      %{latency: 1, larceny: 20},
      %{request_path: inspect(self()), status_code: 404, more: "things", tag: :other}
    )
  end

  def fire_example3 do
    :telemetry.execute(
      [:smoke, :example, :done],
      %{latency: 7, larceny: 21},
      %{request_path: inspect(self()), status_code: 404, more: "beyond", tag: :other}
    )
  end

  def fire_example4 do
    :telemetry.execute(
      [:smoke, :example, :done],
      %{latency: 7, larceny: 21},
      %{request_path: inspect(self()), status_code: 404, more: "beyond", tag: :other}
    )
  end
end
