defmodule AocBot.Command do
  @moduledoc """
  Behaviour for Discord slash commands.

  Each command module implements `definition/0` and `execute/1`.
  The `use AocBot.Command` macro provides the behaviour and helper imports.

  ## Example

      defmodule AocBot.Commands.Ping do
        use AocBot.Command

        @impl AocBot.Command
        def definition, do: %{name: "ping", description: "Check if alive"}

        @impl AocBot.Command
        def execute(interaction) do
          respond(interaction, container(0x00FF00, [text("Pong!")]))
        end
      end
  """

  @doc "Returns the slash command definition map for Discord API"
  @callback definition() :: map()

  @doc "Executes the command, sending the response directly"
  @callback execute(interaction :: map()) :: :ok | {:error, term()}

  defmacro __using__(_opts) do
    quote do
      @behaviour AocBot.Command
      import AocBot.Command.Helpers
      require Logger
    end
  end
end
