defmodule AocBot.TodayPing do
  import Nostrum.Struct.Embed
  alias Nostrum.Api
  alias AocBot.Commands
  alias AocBot.ServerConfig
  require Logger

  @moduledoc """
  Responsible for fetching the daily Advent of Code challenge title and sending notifications to configured Discord channels.
  """

  @doc "Send today's challenge to all configured servers (for scheduled job)"
  def send_today_ping(ping \\ false) do
    today = Date.utc_today()

    if today.month == 12 and today.day in 1..25 do
      case fetch_challenge_title(today) do
        {:ok, challenge_title} ->
          # Send to all configured servers
          ServerConfig.all_configured()
          |> Enum.each(fn config ->
            if config.channel_id do
              send_to_channel(config, challenge_title, today, ping)
            end
          end)

        {:error, reason} ->
          Logger.error("Failed to fetch challenge title: #{reason}")
      end
    else
      Logger.info("Not December or out of date range, skipping today ping")
    end
  end

  @doc "Send today's challenge to a specific guild (for /today command)"
  def send_for_guild(guild_id) do
    today = Date.utc_today()

    cond do
      today.month != 12 or today.day not in 1..25 ->
        {:error, :not_december}

      true ->
        case ServerConfig.get(guild_id) do
          {:ok, config} when not is_nil(config.channel_id) ->
            case fetch_challenge_title(today) do
              {:ok, challenge_title} ->
                send_to_channel(config, challenge_title, today, false)
                :ok

              {:error, reason} ->
                {:error, reason}
            end

          {:ok, _config} ->
            {:error, :not_configured}

          {:error, :not_configured} ->
            {:error, :not_configured}
        end
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
      _ -> "Day #{Date.utc_today().day}"
    end
  end

  defp send_to_channel(config, challenge_title, today, ping) do
    url = challenge_url(today)

    title =
      if today.day == 25 do
        "Merry Christmas! The last challenge of the year is here 🚀"
      else
        "Today's Advent of Code Challenge! 🚀"
      end

    challenge_embed = build_embed(title, challenge_title, url, today)

    content =
      if ping and config.role_to_ping do
        "<@&#{config.role_to_ping}>"
      else
        ""
      end

    Api.Message.create(config.channel_id, content: content, embeds: [challenge_embed])
  end

  defp build_embed(title, challenge_title, url, today) do
    %Nostrum.Struct.Embed{}
    |> put_title(title)
    |> put_description(description(challenge_title, url, today))
    |> put_color(0x009900)
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
