defmodule AocBot.Repo.Migrations.UpdateServerConfigsForSlashCommands do
  use Ecto.Migration

  def change do
    alter table(:server_configs) do
      add :aoc_leaderboard_url, :string
      remove :command_prefix, :string, default: "!"
    end
  end
end
