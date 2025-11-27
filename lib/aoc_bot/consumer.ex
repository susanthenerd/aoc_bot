defmodule AocBot.Consumer do
  @moduledoc """
  Discord event consumer - handles bot ready and interaction events.
  Routes slash commands to their respective command modules.
  """

  require Logger
  @behaviour Nostrum.Consumer

  alias Nostrum.Api
  alias AocBot.Commands

  def handle_event({:READY, %{guilds: guilds}, _ws_state}) do
    Logger.info("Bot ready! Registering slash commands for #{length(guilds)} guild(s)")

    definitions = Commands.all_definitions()

    Enum.each(guilds, fn guild ->
      case Api.ApplicationCommand.bulk_overwrite_guild_commands(guild.id, definitions) do
        {:ok, _} ->
          Logger.info("Registered #{length(definitions)} commands in guild #{guild.id}")

        {:error, err} ->
          Logger.error("Failed to register commands in guild #{guild.id}: #{inspect(err)}")
      end
    end)
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    Logger.debug(
      "Interaction received: type=#{interaction.type}, data=#{inspect(interaction.data)}"
    )

    try do
      handle_interaction(interaction)
    rescue
      e ->
        Logger.error("Interaction error: #{inspect(e)}")

        Api.Interaction.create_response(interaction, %{
          type: 4,
          data: %{content: "An error occurred.", flags: 64}
        })
    end
  end

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
        Logger.warning("Unknown interaction type: #{interaction.type}")
        :ignore
    end
  end

  defp handle_slash_command(interaction) do
    case Commands.get(interaction.data.name) do
      nil ->
        Logger.warning("Unknown command: #{interaction.data.name}")

        Api.Interaction.create_response(interaction, %{
          type: 4,
          data: %{content: "Unknown command", flags: 64}
        })

      module ->
        module.execute(interaction)
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
end
