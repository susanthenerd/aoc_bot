defmodule AocBot.Commands.Help do
  use AocBot.Command

  @impl AocBot.Command
  def definition, do: %{name: "help", description: "Show available commands"}

  @impl AocBot.Command
  def execute(interaction) do
    respond(interaction, container(0x009900, [
      text("# AOC Bot Help"),
      separator(),
      text("""
      **Commands:**
      `/ldr` - Show the Advent of Code leaderboard
      `/tree` - Display a festive Christmas tree
      `/countdown` - Days until Advent of Code ends
      `/random` - Get a random holiday message
      `/help` - Show this help message
      `/ping` - Check if the bot is alive
      `/today` - Post today's Advent of Code challenge

      **Setup (Admin only):**
      `/setup` - Configure the bot for this server
      """)
    ]))
  end
end
