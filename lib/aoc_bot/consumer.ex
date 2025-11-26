defmodule AocBot.Consumer do
  require Logger
  @behaviour Nostrum.Consumer

  alias Nostrum.Api
  alias AocBot.Commands
  alias AocBot.ServerConfig

  # Slash command definitions
  @commands [
    %{name: "ldr", description: "Show the Advent of Code leaderboard"},
    %{name: "tree", description: "Display a festive Christmas tree"},
    %{name: "countdown", description: "Days until Advent of Code / Christmas"},
    %{name: "random", description: "Get a random holiday message"},
    %{name: "help", description: "Show available commands"},
    %{name: "ping", description: "Check if the bot is alive"},
    %{name: "today", description: "Show today's Advent of Code challenge"},
    %{
      name: "setup",
      description: "Configure the bot for this server (Admin only)",
      default_member_permissions: "8",
      options: [
        %{
          name: "channel",
          description: "Channel for bot notifications",
          # CHANNEL
          type: 7,
          required: true,
          # GUILD_TEXT only
          channel_types: [0]
        },
        %{
          name: "role",
          description: "Role to ping for daily challenges",
          # ROLE
          type: 8,
          required: true
        },
        %{
          name: "token",
          description: "Your AOC session cookie (from adventofcode.com)",
          # STRING
          type: 3,
          required: true,
          min_length: 10
        },
        %{
          name: "leaderboard",
          description:
            "Leaderboard URL (e.g. https://adventofcode.com/2024/leaderboard/private/view/12345)",
          # STRING
          type: 3,
          required: true
        }
      ]
    }
  ]

  # Register slash commands when bot is ready
  def handle_event({:READY, %{guilds: guilds}, _ws_state}) do
    Logger.info("Bot ready! Registering slash commands for #{length(guilds)} guild(s)")

    Enum.each(guilds, fn guild ->
      # Bulk overwrite replaces ALL commands - removes old ones not in list
      case Api.ApplicationCommand.bulk_overwrite_guild_commands(guild.id, @commands) do
        {:ok, _} ->
          Logger.info("Registered #{length(@commands)} commands in guild #{guild.id}")

        {:error, err} ->
          Logger.error("Failed to register commands in guild #{guild.id}: #{inspect(err)}")
      end
    end)
  end

  # Handle all interactions
  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    Logger.debug(
      "Interaction received: type=#{interaction.type}, data=#{inspect(interaction.data)}"
    )

    try do
      handle_interaction(interaction)
    rescue
      e ->
        Logger.error("Interaction error: #{inspect(e)}")
        # Try to respond with error
        Api.Interaction.create_response(interaction, %{
          type: 4,
          data: %{content: "❌ An error occurred.", flags: 64}
        })
    end
  end

  # Catch-all for other events
  def handle_event(_event), do: :noop

  defp handle_interaction(interaction) do
    case interaction.type do
      # Application Command (slash command)
      2 ->
        handle_slash_command(interaction)

      # Message Component (button/select)
      3 ->
        handle_component(interaction)

      # Modal Submit
      5 ->
        handle_modal_submit(interaction)

      _ ->
        Logger.warning("Unknown interaction type: #{interaction.type}, #{inspect(interaction)}")
        :ignore
    end
  end

  defp handle_slash_command(interaction) do
    guild_id = interaction.guild_id

    case interaction.data.name do
      "setup" ->
        handle_setup(interaction)

      command ->
        response =
          case command do
            "ldr" -> handle_leaderboard(guild_id)
            "tree" -> Commands.ChristmasTree.embed()
            "countdown" -> Commands.Countdown.embed()
            "random" -> Commands.RandomMessage.embed()
            "help" -> Commands.Help.embed()
            "ping" -> {:content, "Pong! 🏓"}
            "today" -> handle_today(guild_id)
            _ -> {:content, "Unknown command"}
          end

        respond_to_interaction(interaction, response)
    end
  end

  defp handle_component(interaction) do
    Logger.debug("Unknown component: #{interaction.data.custom_id}")
    :ignore
  end

  defp handle_modal_submit(interaction) do
    Logger.debug("Unknown modal: #{interaction.data.custom_id}")
    :ignore
  end

  # Handle /setup command - parse all options and save at once
  defp handle_setup(interaction) do
    guild_id = interaction.guild_id

    # Parse options from command
    options =
      (interaction.data.options || [])
      |> Enum.reduce(%{}, fn opt, acc ->
        Map.put(acc, opt.name, opt.value)
      end)

    channel_id = options["channel"]
    role_id = options["role"]
    token = options["token"]
    leaderboard = options["leaderboard"]

    Logger.debug(
      "Setup: channel=#{channel_id}, role=#{role_id}, token=#{if token, do: "set"}, leaderboard=#{if leaderboard, do: "set"}"
    )

    # Save all at once
    attrs = %{
      channel_id: channel_id,
      role_to_ping: role_id,
      aoc_token: token,
      aoc_leaderboard_url: leaderboard
    }

    case ServerConfig.save_all(guild_id, attrs) do
      {:ok, _config} ->
        summary =
          [
            "**Configuration saved!**",
            "📢 Channel: <##{channel_id}>",
            "🏷️ Role: <@&#{role_id}>",
            "🔑 Token: Set",
            "📊 Leaderboard: Set"
          ]
          |> Enum.join("\n")

        Api.Interaction.create_response(interaction, %{
          type: 4,
          data: %{content: summary, flags: 64}
        })

      {:error, err} ->
        Logger.error("Setup save error: #{inspect(err)}")

        Api.Interaction.create_response(interaction, %{
          type: 4,
          data: %{content: "❌ Failed to save configuration. Please try again.", flags: 64}
        })
    end
  end

  # Command handlers

  defp handle_leaderboard(guild_id) do
    case Commands.Leaderboard.get_leaderboard(guild_id) do
      {:ok, embed} ->
        embed

      {:error, :not_configured} ->
        {:content, "⚠️ Server not configured. Ask an admin to run `/setup`."}

      {:error, :token_not_set} ->
        {:content, "⚠️ AOC token not set. Ask an admin to run `/setup`."}

      {:error, :leaderboard_not_set} ->
        {:content, "⚠️ Leaderboard URL not set. Ask an admin to run `/setup`."}

      {:error, :invalid_token} ->
        {:content, "❌ Invalid AOC token. Ask an admin to update `/setup`."}

      {:error, :leaderboard_not_found} ->
        {:content, "❌ Leaderboard not found. Ask an admin to check `/setup`."}

      {:error, reason} ->
        Logger.error("Leaderboard fetch error: #{inspect(reason)}")
        {:content, "❌ Failed to fetch leaderboard. Try again later."}
    end
  end

  defp handle_today(guild_id) do
    case AocBot.TodayPing.send_for_guild(guild_id) do
      :ok ->
        {:content, "✅ Today's challenge has been posted!"}

      {:error, :not_december} ->
        {:content, "🎄 Advent of Code only runs in December!"}

      {:error, :not_configured} ->
        {:content, "⚠️ Channel not configured. Ask an admin to run `/setup`."}

      {:error, reason} ->
        Logger.error("Today command error: #{inspect(reason)}")
        {:content, "❌ Failed to post today's challenge."}
    end
  end

  # Helper to respond to interactions
  defp respond_to_interaction(interaction, {:content, content}) do
    Api.Interaction.create_response(interaction, %{
      type: 4,
      data: %{content: content},
      flags: 32_768
    })
  end

  defp respond_to_interaction(interaction, data) do
    dbg(data)

    Api.Interaction.create_response(interaction, %{
      type: 4,
      data: data
    })
  end
end
