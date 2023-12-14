defmodule AocBot.Commands.Help do
  import Nostrum.Struct.Embed
  alias Nostrum.Api

  def run(message) do
    embed =
      %Nostrum.Struct.Embed{}
      |> put_title("Help")
      |> put_color(0x009900)
      |> put_description("Use `=ldr X` to get the leaderboard \n Returns first 20 people starting from `X`. By default `X` is `0`")

    Api.create_message(message.channel_id, embeds: [embed])
  end
end
