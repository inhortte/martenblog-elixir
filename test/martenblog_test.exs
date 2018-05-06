defmodule MartenblogTest do
  use ExUnit.Case
  doctest Martenblog

  test "greets the world" do
    assert Martenblog.hello() == :world
  end
end
