defmodule AocBot.TodayPing do
  import Nostrum.Struct.Embed
  alias Nostrum.Api
  alias AocBot.Commands
  require Logger
  alias HTTPoison

  @moduledoc """
  Responsible for fetching the daily Advent of Code challenge title and sending notifications to a specified Discord channel.
  """

  def send_today_ping(ping \\ false) do
    today = Date.utc_today()

    if today.month == 12 and today.day in 1..25 do
      case fetch_challenge_title(today) do
        {:ok, challenge_title} ->
          send_ping_message(challenge_title, today, ping)

        {:error, reason} ->
          Logger.error("Failed to fetch challenge title: #{reason}")
      end
    else
      Logger.info("Not December or out of date range, skipping today ping")
    end
  end

  defp fetch_challenge_title(today) do
    case HTTPoison.get(challenge_url(today)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, extract_challenge_title(body)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp challenge_url(%Date{year: year, day: day}),
    do: "https://adventofcode.com/#{year}/day/#{day}"

  defp extract_challenge_title(html) do
    case Regex.run(~r/<h2>(.*?)<\/h2>/, html) do
      [_, title] -> title
      _ -> {:error, "Title not found"}
    end
  end

  defp send_ping_message(challenge_title, %Date{day: 25} = today, ping) do
    send_message(
      "Merry Christmas! The last challenge of the year is here 🚀",
      challenge_title,
      today,
      ping
    )
  end

  defp send_ping_message(challenge_title, today, ping) do
    send_message("Today's Advent of Code Challenge! 🚀", challenge_title, today, ping)
  end

  defp send_message(title, challenge_title, today, ping) do
    channel_id = Application.get_env(:aoc_bot, :channel_id)
    role_id = Application.get_env(:aoc_bot, :role_id)
    url = challenge_url(today)

    challenge_embed = build_embed(title, challenge_title, url, today)

    content = if ping do
      "<@&#{role_id}>"
    else
      ""
    end

    Api.create_message(channel_id, content: content, embed: challenge_embed)
  end

  defp build_embed(title, challenge_title, url, today) do
    embed_color = 0x009900

    %Nostrum.Struct.Embed{}
    |> put_title(title)
    |> put_description(description(challenge_title, url, today))
    |> put_color(embed_color)
  end

  defp description(challenge_title, url, %Date{day: 25}) do
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

    PS: #{Commands.Countdown.days_until()}
    """
  end

  defp description(challenge_title, url, _) do
    """
    Good morning, Code Wizards! Today's challenge is ready for you.

    Challenge Title: **[#{challenge_title}](#{url})**

    And here's a Christmas tree to get you in the spirit:

    ```ansi
    #{Commands.ChristmasTree.generate(15)}
    ```
    **Random Message of the Day:**
    > #{Commands.RandomMessage.get_random_message()}

    PS: #{Commands.Countdown.days_until()}
    """
  end
end
