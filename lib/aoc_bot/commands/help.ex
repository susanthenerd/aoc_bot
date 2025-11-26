defmodule AocBot.Commands.Help do
  import Nostrum.Struct.Embed

  def embed do
    %Nostrum.Struct.Embed{}
    |> put_title("AOC Bot Help")
    |> put_color(0x009900)
    |> put_description("""
    **Commands:**
    `/ldr` - Show the Advent of Code leaderboard
    `/tree` - Display a festive Christmas tree
    `/countdown` - Days until Advent of Code / Christmas
    `/random` - Get a random holiday message
    `/help` - Show this help message
    `/ping` - Check if the bot is alive
    `/today` - Post today's Advent of Code challenge

    **Setup (Admin only):**
    `/setup` - Opens configuration form
    """)
  end
end
