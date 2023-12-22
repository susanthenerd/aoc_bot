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

  @spec send_today_ping :: :ok
  def send_today_ping do
    today = Date.utc_today()
    url = "https://adventofcode.com/#{today.year}/day/#{today.day}"
    challenge_title = fetch_challenge_title()

    channel_id = Application.get_env(:aoc_bot, :channel_id)
    role_id = Application.get_env(:aoc_bot, :role_id)

    # Define a colorful and fun embed for the challenge announcement
    # Initialize a new Embed struct
    challenge_embed =
      %Nostrum.Struct.Embed{}
      |> put_title("Today's Advent of Code Challenge! 🚀")
      |> put_description("""
      Good morning, Code Wizards! Today's challenge is ready for you.

      Challenge Title: **[#{challenge_title}](#{url})**

      And here's a Christmas tree to get you in the spirit:

      ```ansi
      #{AocBot.Commands.ChristmasTree.generate(15)}
      ```
      **Random Message of the Day:**
      > #{AocBot.Commands.RandomMessage.get_random_message()}

      PS: #{AocBot.Commands.Countdown.days_until_christmas()}
      """)
      |> put_color(0x009900)

    Api.create_message(channel_id,
      content: "<@&#{role_id}>",
      embed: challenge_embed
    )
  end
end
