defmodule AocBot.Commands.Help do
  import Nostrum.Struct.Embed
  alias Nostrum.Api

  def run(message) do
    embed =
      %Nostrum.Struct.Embed{}
      |> put_title("Help")
      |> put_color(0x009900)
      |> put_description("Use `=ldr` to get the leaderboard")

    Api.create_message(message.channel_id, embeds: [embed])
  end
end
