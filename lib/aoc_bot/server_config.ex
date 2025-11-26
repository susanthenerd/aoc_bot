defmodule AocBot.ServerConfig do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:discord_server_id, :id, autogenerate: false}
  schema "server_configs" do
    field(:channel_id, :id)
    field(:role_to_ping, :string)
    field(:command_prefix, :string, default: "=")
    field(:aoc_token, :string)

    timestamps()
  end

  @doc false
  def changeset(server_config, attrs) do
    server_config
    |> cast(attrs, [:discord_server_id, :channel_id, :role_to_ping, :command_prefix, :aoc_token])
    |> validate_required([:discord_server_id, :channel_id])
    |> unique_constraint(:discord_server_id, name: :server_configs_pkey)
  end
end
