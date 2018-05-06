defmodule Martenblog.Nigger do
  require Logger
  
  def init(opts), do: opts

  def call(conn, opts) do
    Logger.info "DEATH to #{opts[:name]}"
    conn
  end
end
