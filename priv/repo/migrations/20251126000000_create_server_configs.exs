defmodule AocBot.Repo.Migrations.CreateServerConfigs do
  use Ecto.Migration

  def change do
    create table(:server_configs, primary_key: false) do
      add :discord_server_id, :bigint, primary_key: true
      add :channel_id, :bigint, null: false
      add :role_to_ping, :string
      add :command_prefix, :string, default: "!", null: false
      add :aoc_token, :string

      timestamps()
    end

    create index(:server_configs, [:channel_id])
  end
end
