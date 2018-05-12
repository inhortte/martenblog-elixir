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
      applications: [:cowboy, :mongodb, :poolboy, :plug, :absinthe_plug],
      extra_applications: [:logger],
      mod: {Martenblog.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.0"},
      {:mongodb, ">= 0.0.0"},
      {:poolboy, ">= 0.0.0"},
      {:absinthe_plug, "~> 1.4.0"},
      {:cors_plug, "~> 1.5"},      
      {:poison, "~> 1.3.0"}
    ]
  end
end
