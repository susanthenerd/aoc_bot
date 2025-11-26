import Config

# Static compile-time configuration

# Nostrum gateway intents
config :nostrum,
  gateway_intents: [:guild_messages, :message_content]

# Scheduler configuration
config :aoc_bot, AocBot.Scheduler,
  jobs: [
    # Daily ping at 5 AM during December
    {"0 5 * 12 *", {AocBot.TodayPing, :send_today_ping, [true]}}
  ]

# Import environment-specific config (runtime secrets)
import_config "runtime.exs"
