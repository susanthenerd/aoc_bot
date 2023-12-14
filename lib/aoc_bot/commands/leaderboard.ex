defmodule AocBot.Commands.Leaderboard do
  import Nostrum.Struct.Embed
  alias Nostrum.Api
  alias TableRex.Table
  require Logger

  @header ["Scr.", "Name", "★★"]

  defp get_name(member) do
    case member["name"] do
      name when is_nil(name) ->
        "(anonymous ##{member["id"]})"

      name ->
        name
    end
  end

  defp format({_id, member}) do
    ["#{member["local_score"]}", get_name(member), member["stars"]]
  end

  defp extract_number(number_list) do
    case number_list do
      [] ->
        0

      [number_str] ->
        parse_single_element(number_str)

      _ ->
        0
    end
  end

  defp parse_single_element(element) do
    case Integer.parse(element) do
      {number, ""} ->
        number

      _ ->
        0
    end
  end

  def run(msg, extra) do
    embed = extract_number(extra) |> get_leaderboard()
    Api.create_message(msg.channel_id, embeds: [embed])
  end

  defp get_members(start) do
    AocBot.Fetcher.get_data()["members"]
    |> Enum.sort_by(fn {_, member} -> member["local_score"] end, &>=/2)
    |> Enum.map(&format/1)
    |> (fn list ->
          if Enum.count(list) > start do
            Enum.slice(list, start, 20)
          else
            Enum.slice(list, 0, 20)
          end
        end).()
  end

  defp get_leaderboard(start) do
    members = get_members(start)

    table =
      Table.new(members, @header)
      |> Table.put_column_meta(2, color: :yellow, align: :right)
      |> Table.put_column_meta(0, color: :red, align: :right)
      |> Table.put_header_meta(0..2, color: :blue, padding: 0)
      |> Table.put_column_meta(0..2, padding: 0)

    embed =
      %Nostrum.Struct.Embed{}
      |> put_title("Leaderboard")
      |> put_url("https://adventofcode.com/2023/leaderboard/private/view/1064509")
      |> put_color(0x009900)
      |> put_description("```ansi
#{Table.render!(table, horizontal_style: :header, vertical_style: :off, header_separator_symbol: "=", bottom_frame_symbol: "", top_frame_symbol: "")}
```")

    embed
  end
end
