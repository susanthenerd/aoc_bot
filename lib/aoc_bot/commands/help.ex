defmodule AocBot.Commands.Help do
  import Nostrum.Struct.Embed
  alias Nostrum.Api

  def run(message) do
    embed =
      %Nostrum.Struct.Embed{}
      |> put_title("Help")
      |> put_color(0x009900)
      |> put_description("
**Commands:**
`=ldr` - Show the leaderboard
`=tree` - Show a Christmas tree
`=countdown` - Show the number of days until Christmas
`=random` - Show a random message
`=help` - Show this help message
`=today` - Today's Advent of Code challenge

")
    Api.create_message(message.channel_id, embeds: [embed])
  end
end
