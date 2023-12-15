defmodule AocBot.TodayPing do
  import Nostrum.Struct.Embed
  alias Nostrum.Api

  @moduledoc """
  AocBot.TodayPing is responsible for interacting with the Advent of Code website to fetch the daily challenge title and send notifications to a specified Discord channel.
  """

  @spec fetch_challenge_title :: String.t() | {:error, any()}
  defp fetch_challenge_title do
    today = Date.utc_today()
    url = "https://adventofcode.com/#{today.year}/day/#{today.day}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        extract_challenge_title(body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @spec extract_challenge_title(String.t()) :: String.t()
  defp extract_challenge_title(html) do
    [_, title | _] = Regex.run(~r/<h2>(.*?)<\/h2>/, html)
    title
  end

  @doc """
  Sends a message to the Discord channel with the current day's AoC challenge and the final leaderboard.

  Utilizes the Discord API to create messages with embedded content.
  """
  @spec send_today_ping :: :ok
  def send_today_ping do
    today = Date.utc_today()
    url = "https://adventofcode.com/#{today.year}/day/#{today.day}"
    challenge_title = fetch_challenge_title()

    channel_id = Application.get_env(:aoc_bot, :channel_id)
    role_id = Application.get_env(:aoc_bot, :role_id)

    # Fetch the leaderboard data
    _embed_leaderboard =
      AocBot.Commands.Leaderboard.get_leaderboard(0)
      |> put_title("The final leaderboard for yesterday is here!")

    # Api.create_message(channel_id, embeds: [embed_leaderboard])

    Api.create_message(channel_id,
      content: "Trezirea <@&#{role_id}>!\n
      Problema de azi este [#{challenge_title}](#{url})"
    )
  end
end
