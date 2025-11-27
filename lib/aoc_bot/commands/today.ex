defmodule AocBot.Commands.Today do
  use AocBot.Command

  @impl AocBot.Command
  def definition, do: %{name: "today", description: "Show today's Advent of Code challenge"}

  @impl AocBot.Command
  def execute(interaction) do
    case AocBot.TodayPing.send_for_guild(interaction.guild_id) do
      :ok ->
        respond_ephemeral(interaction, "Today's challenge has been posted!")

      {:error, :not_december} ->
        respond_ephemeral(interaction, "Advent of Code only runs in December!")

      {:error, :not_configured} ->
        respond_ephemeral(interaction, "Channel not configured. Ask an admin to run `/setup`.")

      {:error, reason} ->
        Logger.error("Today command error: #{inspect(reason)}")
        respond_ephemeral(interaction, "Failed to post today's challenge.")
    end
  end
end
