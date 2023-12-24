defmodule AocBot.TodayPing do
  import Nostrum.Struct.Embed
  alias Nostrum.Api
  alias AocBot.Commands

  @moduledoc """
  AocBot.TodayPing is responsible for interacting with the Advent of Code website to fetch the daily challenge title and send notifications to a specified Discord channel.
  """

  # Utility functions for dates and URLs
  defp today(), do: Date.utc_today()
  defp is_december?(%Date{month: 12}), do: true
  defp is_december?(_), do: false

  # Fetching challenge title
  defp fetch_challenge_title do
    case HTTPoison.get(challenge_url()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        extract_challenge_title(body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp challenge_url do
    today = today()
    "https://adventofcode.com/#{today.year}/day/#{today.day}"
  end

  defp extract_challenge_title(html) do
    [_, title | _] = Regex.run(~r/<h2>(.*?)<\/h2>/, html)
    title
  end

  # Sending the ping
  def send_today_ping do
    today = today()

    case {is_december?(today), today.day} do
      {true, day} when day in 1..25 ->
        challenge_title = fetch_challenge_title()
        send_ping_message(challenge_title, today)

      _ ->
        Logger.info("Not December or out of date range, skipping today ping")
    end
  end

  defp send_ping_message(challenge_title, %Date{day: 25} = _today) do
    send_message(
      "Merry Christmas! The last challenge of the year is here 🚀",
      challenge_title,
      true
    )
  end

  defp send_ping_message(challenge_title, _today) do
    send_message("Today's Advent of Code Challenge! 🚀", challenge_title, false)
  end

  # Creating and sending the actual message
  defp send_message(title, challenge_title, is_christmas) do
    channel_id = Application.get_env(:aoc_bot, :channel_id)
    role_id = Application.get_env(:aoc_bot, :role_id)
    url = challenge_url()

    challenge_embed =
      build_embed(title, challenge_title, url, is_christmas)

    Api.create_message(channel_id, content: "<@&#{role_id}>", embed: challenge_embed)
  end

  # Constructing the embed message
  defp build_embed(title, challenge_title, url, is_christmas) do
    base_embed =
      %Nostrum.Struct.Embed{}
      |> put_title(title)
      |> put_description(description(challenge_title, url, is_christmas))
      |> put_color(0x009900)

    base_embed
  end

  defp description(challenge_title, url, true) do
    """
    🎄 Merry Christmas, Code Wizards! 🎄

    Today is a day of joy, celebration, and one last hoorah of coding challenges for the year! As you dive into today's problem, take a moment to reflect on all the puzzles you've conquered.

    Challenge Title: **[#{challenge_title}](#{url})**

    Feel the holiday spirit with the final Christmas tree of the season:
    ```ansi
    #{Commands.ChristmasTree.generate(15)}
    ```

    Random Message of the Day:
    #{Commands.RandomMessage.get_random_message()}

    As you celebrate, remember, every line of code you've written this month has led to this moment. Cherish it, enjoy today's challenge, and have a wonderful Christmas filled with happiness and code!

    PS: #{Commands.Countdown.days_until_christmas()}
    """
  end

  defp description(challenge_title, url, false) do
    """
    Good morning, Code Wizards! Today's challenge is ready for you.

    Challenge Title: **[#{challenge_title}](#{url})**

    And here's a Christmas tree to get you in the spirit:

    ```ansi
    #{Commands.ChristmasTree.generate(15)}
    ```
    **Random Message of the Day:**
    > #{Commands.RandomMessage.get_random_message()}

    PS: #{Commands.Countdown.days_until_christmas()}
    """
  end
end
