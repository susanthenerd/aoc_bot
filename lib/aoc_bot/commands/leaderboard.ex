defmodule AocBot.Commands.Leaderboard do
  use AocBot.Command
  alias TableRex.Table

  @header ["Score", "", "Name", "Stars"]

  @impl AocBot.Command
  def definition, do: %{name: "ldr", description: "Show the Advent of Code leaderboard"}

  @impl AocBot.Command
  def execute(interaction) do
    guild_id = interaction.guild_id

    case AocBot.Fetcher.get_data(guild_id) do
      {:ok, data} ->
        respond(interaction, build_response(data, guild_id))

      {:error, :not_configured} ->
        respond_ephemeral(interaction, "Server not configured. Ask an admin to run `/setup`.")

      {:error, :token_not_set} ->
        respond_ephemeral(interaction, "AOC token not set. Ask an admin to run `/setup`.")

      {:error, :leaderboard_not_set} ->
        respond_ephemeral(interaction, "Leaderboard URL not set. Ask an admin to run `/setup`.")

      {:error, :invalid_token} ->
        respond_ephemeral(interaction, "Invalid AOC token. Ask an admin to update `/setup`.")

      {:error, :leaderboard_not_found} ->
        respond_ephemeral(interaction, "Leaderboard not found. Ask an admin to check `/setup`.")

      {:error, reason} ->
        Logger.error("Leaderboard fetch error: #{inspect(reason)}")
        respond_ephemeral(interaction, "Failed to fetch leaderboard. Try again later.")
    end
  end

  defp build_response(data, guild_id) do
    members = get_members(data["members"], 0)
    table = build_table(members)

    url =
      case AocBot.ServerConfig.get(guild_id) do
        {:ok, config} -> config.aoc_leaderboard_url
        _ -> nil
      end

    timestamp =
      case AocBot.Fetcher.get_last_fetch_time(guild_id) do
        nil -> ""
        ts -> "\n-# Last updated: #{format_timestamp(ts)}"
      end

    url_line = if url, do: "\n[View on adventofcode.com](#{url})", else: ""

    container(0x009900, [
      text("# Leaderboard"),
      separator(),
      text("```ansi\n#{table}\n```"),
      separator(),
      text("""
      **Random Message:**
      > #{AocBot.Commands.RandomMessage.get_random_message()}

      #{AocBot.Commands.Countdown.days_until()}#{url_line}#{timestamp}
      """)
    ])
  end

  defp build_table(members) do
    Table.new(members, @header)
    |> Table.put_column_meta(3, color: :green, align: :right)
    |> Table.put_column_meta(0, color: :red, align: :right)
    |> Table.put_header_meta(0..3, color: :yellow)
    |> Table.put_header_meta(3, align: :left)
    |> Table.render!(
      horizontal_style: :header,
      vertical_style: :off,
      header_separator_symbol: "=",
      bottom_frame_symbol: "",
      top_frame_symbol: "",
      intersection_symbol: "",
      vertical_symbol: ""
    )
  end

  defp get_members(data, start) do
    data
    |> Enum.sort_by(fn {_, member} -> member["local_score"] end, &>=/2)
    |> Enum.with_index(1)
    |> Enum.map(fn {{id, member}, rank} -> format({id, member}, rank) end)
    |> then(fn list ->
      if Enum.count(list) > start do
        Enum.slice(list, start, 20)
      else
        Enum.slice(list, 0, 20)
      end
    end)
  end

  defp format({_id, member}, rank) do
    score = member["local_score"]
    emoji = rank_emoji(rank, score)
    [score, emoji, get_name(member), member["stars"]]
  end

  defp rank_emoji(1, _), do: "1st"
  defp rank_emoji(2, _), do: "2nd"
  defp rank_emoji(3, _), do: "3rd"
  defp rank_emoji(_, score) when score > 1800, do: "***"
  defp rank_emoji(_, score) when score > 1500, do: "**"
  defp rank_emoji(_, _), do: "*"

  defp get_name(member) do
    case member["name"] do
      nil -> "(elf ##{member["id"]})"
      name -> name
    end
  end

  defp format_timestamp(timestamp) do
    timestamp
    |> DateTime.truncate(:second)
    |> Calendar.strftime("%Y-%m-%d %H:%M UTC")
  end
end
