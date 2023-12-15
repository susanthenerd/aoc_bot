defmodule AocBot.Consumer do
  require Logger
  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Logger.debug(msg)

    case String.split(msg.content) do
      ["=ping" | _rest] ->
        Api.create_message(msg.channel_id, "Pong!")

      ["=ldr" | extra] ->
        AocBot.Commands.Leaderboard.run(msg, extra)

      ["=help" | _rest] ->
        AocBot.Commands.Help.run(msg)

      ["=todaytest" | _rest] ->
        AocBot.TodayPing.send_today_ping()

      _ ->
        :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end
end
