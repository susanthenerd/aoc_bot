defmodule AocBot.Commands.Leaderboard do
  import Nostrum.Struct.Embed
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
        1 -> "🥇"
        2 -> "🥈"
        3 -> "🥉"
        _ ->
          case score do
            score when score > 1800 -> "🎄"
            score when score > 1500 -> "⛄"
            _ -> "🍪"
          end
      end

    ["#{score} #{emoji}", get_name(member), member["stars"]]
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

  @doc "Get leaderboard embed for a guild. Returns {:ok, embed} or {:error, reason}"
  def get_leaderboard(guild_id) do
    case AocBot.Fetcher.get_data(guild_id) do
      {:ok, data} ->
        {:ok, build_embed(data, guild_id)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_embed(data, guild_id) do
    members = get_members(data["members"], 0)

    table =
      Table.new(members, @header)
      |> Table.put_column_meta(2, color: :green, align: :right)
      |> Table.put_column_meta(0, color: :red, align: :right)
      |> Table.put_header_meta(0..2, color: :yellow)
      |> Table.put_header_meta(2, align: :left)

    # Get the leaderboard URL for the link
    url = case AocBot.ServerConfig.get(guild_id) do
      {:ok, config} -> config.aoc_leaderboard_url
      _ -> nil
    end

    embed = %Nostrum.Struct.Embed{}
    |> put_title("Leaderboard")
    |> put_color(0x009900)
    |> put_description("```ansi
#{Table.render!(table, horizontal_style: :header, vertical_style: :off, header_separator_symbol: "=", bottom_frame_symbol: "", top_frame_symbol: "", intersection_symbol: "", vertical_symbol: "")}
```
**Random Message:**
> #{AocBot.Commands.RandomMessage.get_random_message()}

PS: #{AocBot.Commands.Countdown.days_until()}
")

    # Add URL if available
    embed = if url, do: put_url(embed, url), else: embed

    # Add timestamp if available
    case AocBot.Fetcher.get_last_fetch_time(guild_id) do
      nil -> embed
      timestamp -> put_timestamp(embed, timestamp)
    end
  end
end
