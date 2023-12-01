defmodule AocBotTest do
  use ExUnit.Case
  doctest AocBot

  test "greets the world" do
    assert AocBot.hello() == :world
  end
end
