defmodule DriverSensor.MixProject do
  use Mix.Project

  def project do
    [
      app: :driver_sensor,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DriverSensor.Application, []},
      
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:emqtt, github: "emqx/emqtt", tag: "1.8.6", system_env: [{"BUILD_WITHOUT_QUIC", "1"}]},
      {:cowlib, "2.12.1", override: true},
      {:jason, "~> 1.2"},
    ]
  end
end
