defmodule Martenblog.MixProject do
  use Mix.Project

  def project do
    [
      app: :martenblog,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        prod: [
          version: "0.0.1",
          applications: [martenblog: :permanent],
          cookie: "thurk",
          include_executables_for: [:unix], # we'll be deploying to Linux only
          steps: [:assemble, :tar] # have Mix automatically create a tarball after assembly
        ]
      ],
      escript: [main_module: Martenblog, emu_args: ["-name martenblog@tahr.nebula -setcookie thurk"]]
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
      {:fuzzyurl, "~> 1.0.1"},
      { :timex, "~> 3.6.3" },
      {:html_sanitize_ex, "~> 1.3.0-rc3"},
      {:postgrex, "~> 0.14.3"},
      { :earmark, "~> 1.4.13" },
      {:mix_systemd, "~> 0.7"}
    ]
  end
end


