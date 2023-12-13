defmodule AocBot.Commands.Leaderboard do
  import Nostrum.Struct.Embed
  alias Nostrum.Api
  alias TableRex.Table
  require Logger

  @header ["Score", "Name", "Stars"]

  defp format({_id, member}) do
    case member["name"] do
      name when is_nil(name) ->
        [member["local_score"], "(anonymous user ##{member["id"]})", member["stars"]]

      name ->
        [member["local_score"], name, member["stars"]]
    end
  end

  def run(msg) do
    members =
      AocBot.Fetcher.get_data()["members"]
      |> Enum.sort_by(fn {_, member} -> member["local_score"] end, &>=/2)
      |> Enum.map(&format/1)
      |> Enum.take(20)

    table =
      Table.new(members, @header)
      |> Table.put_column_meta(0, color: :yellow)
      |> Table.put_header_meta(0..2, color: :green)
      |> Table.put_column_meta(2, align: :right)

    embed =
      %Nostrum.Struct.Embed{}
      |> put_title("Leaderboard")
      |> put_url("https://adventofcode.com/2023/leaderboard/private/view/1064509")
      |> put_color(0x009900)
      |> put_description("```ansi
#{Table.render!(table, horizontal_style: :header)}```")

    Api.create_message(msg.channel_id, embeds: [embed])
  end
end
