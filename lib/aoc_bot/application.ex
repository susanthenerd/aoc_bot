defmodule AocBot.Application do
  use Application

  def start(_type, _args) do
    # Initialize ETS cache for fetcher before starting children
    AocBot.Fetcher.init_cache()

    bot_options = %{
      consumer: AocBot.Consumer,
      intents: [:guild_messages, :message_content],
      wrapped_token: fn -> System.get_env("DISCORD_TOKEN") end,
      log_full_events: Mix.env() == :dev
    }

    children = [
      AocBot.Repo,
      AocBot.Scheduler,
      {Nostrum.Bot, bot_options}
    ]

    opts = [strategy: :one_for_one, name: AocBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
