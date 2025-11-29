defmodule AocBot.TodayPing do
  @moduledoc """
  Responsible for fetching the daily Advent of Code challenge title
  and sending notifications to configured Discord channels.
  """

  import AocBot.Command.Helpers
  alias AocBot.Commands
  alias AocBot.ServerConfig
  require Logger

  @doc "Send today's challenge to all configured servers (for scheduled job)"
  def send_today_ping(ping \\ false) do
    today = Date.utc_today()

    if today.month == 12 and today.day in 1..12 do
      case fetch_challenge_title(today) do
        {:ok, challenge_title} ->
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
      today.month != 12 or today.day not in 1..12 ->
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
    message = build_message(challenge_title, url, today)

    content =
      if ping and config.role_to_ping do
        "<@&#{config.role_to_ping}>"
      else
        ""
      end

    send_message(config.channel_id, message, content: content)
  end

  defp build_message(challenge_title, url, %Date{year: year, day: 12}) do
    container(0x009900, [
      text("# The Final Day of Advent of Code #{year}!"),
      separator(),
      text("""
      Code Wizards, we've reached the twelfth and final day!

      This year's Advent of Code journey comes to a close. As you tackle this last challenge, take a moment to celebrate all twelve puzzles you've conquered.

      **Challenge:** [#{challenge_title}](#{url})
      """),
      separator(false),
      ansi_block(Commands.ChristmasTree.generate(15)),
      separator(),
      text("""
      **Random Message:**
      > #{Commands.RandomMessage.get_random_message()}

      Thank you for coding along through all 12 days of Advent of Code #{year}—you've earned your stars!

      #{Commands.Countdown.days_until()}
      """)
    ])
  end

  defp build_message(challenge_title, url, _today) do
    container(0x009900, [
      text("# Today's Advent of Code Challenge!"),
      separator(),
      text("""
      Good morning, Code Wizards! Today's challenge is ready for you.

      **Challenge:** [#{challenge_title}](#{url})
      """),
      separator(false),
      ansi_block(Commands.ChristmasTree.generate(15)),
      separator(),
      text("""
      **Random Message:**
      > #{Commands.RandomMessage.get_random_message()}

      #{Commands.Countdown.days_until()}
      """)
    ])
  end
end
