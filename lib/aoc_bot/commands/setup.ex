defmodule AocBot.Commands.Setup do
  use AocBot.Command
  alias AocBot.ServerConfig

  @impl AocBot.Command
  def definition do
    %{
      name: "setup",
      description: "Configure the bot for this server (Admin only)",
      default_member_permissions: "8",
      options: [
        %{
          name: "channel",
          description: "Channel for bot notifications",
          type: 7,
          required: true,
          channel_types: [0]
        },
        %{
          name: "role",
          description: "Role to ping for daily challenges",
          type: 8,
          required: true
        },
        %{
          name: "token",
          description: "Your AOC session cookie (from adventofcode.com)",
          type: 3,
          required: true,
          min_length: 10
        },
        %{
          name: "leaderboard",
          description: "Leaderboard URL (e.g. https://adventofcode.com/2025/leaderboard/private/view/12345)",
          type: 3,
          required: true
        }
      ]
    }
  end

  @impl AocBot.Command
  def execute(interaction) do
    guild_id = interaction.guild_id
    options = parse_options(interaction.data.options || [])

    Logger.debug(
      "Setup: channel=#{options["channel"]}, role=#{options["role"]}, " <>
        "token=#{if options["token"], do: "set"}, leaderboard=#{if options["leaderboard"], do: "set"}"
    )

    attrs = %{
      channel_id: options["channel"],
      role_to_ping: options["role"],
      aoc_token: options["token"],
      aoc_leaderboard_url: options["leaderboard"]
    }

    case ServerConfig.save_all(guild_id, attrs) do
      {:ok, _config} ->
        summary =
          [
            "**Configuration saved!**",
            "Channel: <##{options["channel"]}>",
            "Role: <@&#{options["role"]}>",
            "Token: Set",
            "Leaderboard: Set"
          ]
          |> Enum.join("\n")

        respond_ephemeral(interaction, summary)

      {:error, err} ->
        Logger.error("Setup save error: #{inspect(err)}")
        respond_ephemeral(interaction, "Failed to save configuration. Please try again.")
    end
  end

  defp parse_options(options) do
    Enum.reduce(options, %{}, fn opt, acc ->
      Map.put(acc, opt.name, opt.value)
    end)
  end
end
