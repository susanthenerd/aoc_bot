import Config

config :nostrum,
  token: "TOKEN",
  gateway_intents: [:guild_messages, :message_content]

config :aoc_bot,
  url: "https://adventofcode.com/2024/leaderboard/private/view/1064509",
  cookie: "COOKIE",
  channel_id: 1_311_251_162_791_542_794,
  role_id: 1_310_295_228_313_374_751

config :aoc_bot, AocBot.Scheduler,
  jobs: [
    {"0 5 * 12 *", {AocBot.TodayPing, :send_today_ping, [true]}}
  ]
