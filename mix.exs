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
      extra_applications: [:logger],
      mod: {Martenblog.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 1.0.0"},
      {:plug, "~> 1.8.3"},
      {:mongodb, "~> 0.5.0"},
      {:poolboy, "~> 1.5"},
      {:cors_plug, "~> 2.0"},      
      {:poison, "~> 4.0"},
      {:mint, "~> 0.3.0"},
      {:castore, "~> 0.1.2"},
      {:xml_builder, "~> 2.1.1"},
      {:uuid, "~> 1.1.8"},
      {:hackney, "1.15.1"},
      {:fuzzyurl, "~> 0.9.0"},
      { :earmark, "~> 1.4.3" },
      { :timex, "~> 3.6.1" },
      {:html_sanitize_ex, "~> 1.3.0-rc3"},
      {:postgrex, "~> 0.14.3"}
    ]
  end
end
