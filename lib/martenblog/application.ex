defmodule Martenblog.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      {Plug.Cowboy, scheme: :http, plug: Martenblog.Router, options: [port: 8777]},
      # Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: Martenblog.Router, options: [port: 4001]),
      worker(Mongo, [[database:
		      Application.get_env(:martenblog, :db)[:name], name: :mongo]])
    ]

    Application.ensure_all_started(:hackney)
    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
    # Martenblog.Router.start_link
  end
end
