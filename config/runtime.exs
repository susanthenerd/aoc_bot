import Config

# Runtime configuration - loaded at application start
# Reads from environment variables (set in .env for local dev)

# Database configuration
# Uses DATABASE_URL in production (Fly.io sets this automatically)
# Falls back to local postgres in development (devenv uses trust auth)
if database_url = System.get_env("DATABASE_URL") do
  config :aoc_bot, AocBot.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
else
  # Local dev: hostname defaults to localhost, username to OS user
  # No password needed with devenv's trust authentication
  config :aoc_bot, AocBot.Repo,
    database: "aoc_bot_dev",
    stacktrace: true,
    show_sensitive_data_on_connection_error: true,
    pool_size: 10
end

# Ecto repo configuration
config :aoc_bot,
  ecto_repos: [AocBot.Repo]

# Discord token from environment
config :nostrum,
  token: System.get_env("DISCORD_TOKEN")

# Note: Server-specific configuration (channel_id, role_id, aoc_token, etc.)
# is now stored in the database via AocBot.ServerConfig schema
# This allows different settings per Discord server
