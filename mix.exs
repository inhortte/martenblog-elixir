defmodule Martenblog.MixProject do
  use Mix.Project

  def project do
    [
      app: :martenblog,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:cowboy, :mongodb, :poolboy],
      extra_applications: [:logger],
      mod: {Martenblog.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 1.0.0"},
      {:plug, "~> 1.7"},
      {:mongodb, "~> 0.4.7"},
      {:poolboy, "~> 1.5"},
      {:cors_plug, "~> 2.0"},      
      {:poison, "~> 4.0"}
    ]
  end
end
