defmodule AocBot.Commands.Leaderboard do
  import Nostrum.Struct.Embed
  alias Nostrum.Api
  alias TableRex.Table
  require Logger

  @header ["Score 🎁", "Name 🎅", "🌟"]

  defp get_name(member) do
    case member["name"] do
      name when is_nil(name) -> "(elf ##{member["id"]})"
      name -> name
    end
  end

  defp format({_id, member}, rank) do
    score = member["local_score"]

    emoji =
      case rank do
        1 ->
          "🥇"

        2 ->
          "🥈"

        3 ->
          "🥉"

        _ ->
          case score do
            score when score > 1800 -> "🎄"
            score when score > 1500 -> "⛄"
            _ -> "🍪"
          end
      end

    ["#{score} #{emoji}", get_name(member), member["stars"]]
  end

  def run(msg, _extra) do
    embed = get_leaderboard(0)
    Api.create_message(msg.channel_id, embeds: [embed])
  end

  defp get_members(data, start) do
    data
    |> Enum.sort_by(fn {_, member} -> member["local_score"] end, &>=/2)
    |> Enum.with_index(1)
    |> Enum.map(fn {{id, member}, rank} -> format({id, member}, rank) end)
    |> (fn list ->
          if Enum.count(list) > start do
            Enum.slice(list, start, 20)
          else
            Enum.slice(list, 0, 20)
          end
        end).()
  end

  def get_leaderboard(start) do
    data = AocBot.Fetcher.get_data()
    Logger.debug(data)

    members = get_members(data["members"], start)

    table =
      Table.new(members, @header)
      |> Table.put_column_meta(2, color: :green, align: :right)
      |> Table.put_column_meta(0, color: :red, align: :right)
      |> Table.put_header_meta(0..2, color: :yellow)
      |> Table.put_header_meta(2, align: :left)

    embed =
      %Nostrum.Struct.Embed{}
      |> put_title("Leaderboard")
      |> put_url("https://adventofcode.com/2023/leaderboard/private/view/1064509")
      |> put_color(0x009900)
      |> put_description("```ansi
#{Table.render!(table, horizontal_style: :header, vertical_style: :off, header_separator_symbol: "=", bottom_frame_symbol: "", top_frame_symbol: "", intersection_symbol: "", vertical_symbol: "")}
```
**Random Message:**
> #{AocBot.Commands.RandomMessage.get_random_message()}

PS: #{AocBot.Commands.Countdown.days_until_christmas()}
")
      |> put_timestamp(AocBot.Fetcher.get_last_fetch_time())

    embed
  end
end
