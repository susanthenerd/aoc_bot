defmodule AocBot.Consumer do
  require Logger
  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    Logger.debug(msg)

    case msg.content do
      "=ping" ->
        Api.create_message(msg.channel_id, "Pong!")

      "=ldr" ->
        AocBot.Commands.Leaderboard.run(msg)


      "=help" ->
        AocBot.Commands.Help.run(msg)

      _ ->
        :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end
end
