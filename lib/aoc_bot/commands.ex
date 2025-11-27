defmodule AocBot.Commands do
  @moduledoc """
  Command registry - aggregates all command modules and provides lookup.
  """

  @modules [
    AocBot.Commands.Ping,
    AocBot.Commands.Help,
    AocBot.Commands.Countdown,
    AocBot.Commands.RandomMessage,
    AocBot.Commands.ChristmasTree,
    AocBot.Commands.Leaderboard,
    AocBot.Commands.Today,
    AocBot.Commands.Setup
  ]

  @command_map (for module <- @modules, into: %{}, do: {module.definition().name, module})

  @doc "Returns list of all command definitions for Discord API registration"
  def all_definitions do
    Enum.map(@modules, & &1.definition())
  end

  @doc "Get command module by name"
  def get(name), do: Map.get(@command_map, name)

  @doc "List all registered command modules"
  def modules, do: @modules
end
