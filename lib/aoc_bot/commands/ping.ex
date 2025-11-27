defmodule AocBot.Commands.Ping do
  use AocBot.Command

  @impl AocBot.Command
  def definition, do: %{name: "ping", description: "Check if the bot is alive"}

  @impl AocBot.Command
  def execute(interaction) do
    respond(interaction, container(0x00FF00, [
      text("Pong!")
    ]))
  end
end
