defmodule AocBot.Repo do
  use Ecto.Repo,
    otp_app: :aoc_bot,
    adapter: Ecto.Adapters.Postgres
end
