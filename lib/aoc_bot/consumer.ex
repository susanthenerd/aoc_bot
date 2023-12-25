defmodule AocBot.Consumer do
  require Logger
  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case String.split(msg.content) do
      ["=ldr" | extra] ->
        AocBot.Commands.Leaderboard.run(msg, extra)

      ["=tree" | _rest] ->
        AocBot.Commands.ChristmasTree.run(msg)

      ["=countdown" | _rest] ->
        AocBot.Commands.Countdown.run(msg)

      ["=random" | _rest] ->
        AocBot.Commands.RandomMessage.run(msg)

      ["=help" | _rest] ->
        AocBot.Commands.Help.run(msg)

      ["=ping" | _rest] ->
        Api.create_message(msg.channel_id, content: "Pong! 🏓")

      _ ->
        :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end
end
