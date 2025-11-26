defmodule AocBot.ServerConfig do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias AocBot.Repo

  @primary_key {:discord_server_id, :id, autogenerate: false}
  schema "server_configs" do
    field(:channel_id, :id)
    field(:role_to_ping, :id)
    field(:aoc_token, :string)
    field(:aoc_leaderboard_url, :string)

    timestamps()
  end

  @doc false
  def changeset(server_config, attrs) do
    server_config
    |> cast(attrs, [:discord_server_id, :channel_id, :role_to_ping, :aoc_token, :aoc_leaderboard_url])
    |> validate_required([:discord_server_id])
    |> unique_constraint(:discord_server_id, name: :server_configs_pkey)
  end

  @doc "Get config for a guild, returns {:ok, config} or {:error, :not_configured}"
  def get(guild_id) do
    case Repo.get(__MODULE__, guild_id) do
      nil -> {:error, :not_configured}
      config -> {:ok, config}
    end
  end

  @doc "Get or create config for a guild"
  def get_or_create(guild_id) do
    case get(guild_id) do
      {:ok, config} -> {:ok, config}
      {:error, :not_configured} ->
        %__MODULE__{discord_server_id: guild_id}
        |> Repo.insert()
    end
  end

  @doc "Update a specific field for a guild (upsert)"
  def update_field(guild_id, field, value) do
    case Repo.get(__MODULE__, guild_id) do
      nil ->
        # Insert new record with the field
        %__MODULE__{discord_server_id: guild_id}
        |> changeset(%{field => value})
        |> Repo.insert(
          on_conflict: {:replace, [field, :updated_at]},
          conflict_target: :discord_server_id
        )

      config ->
        # Update existing record
        config
        |> changeset(%{field => value})
        |> Repo.update()
    end
  end

  @doc "Set AOC token for a guild"
  def set_token(guild_id, token) do
    update_field(guild_id, :aoc_token, token)
  end

  @doc "Set leaderboard URL for a guild"
  def set_leaderboard_url(guild_id, url) do
    update_field(guild_id, :aoc_leaderboard_url, url)
  end

  @doc "Set channel for bot messages"
  def set_channel(guild_id, channel_id) do
    update_field(guild_id, :channel_id, channel_id)
  end

  @doc "Set role to ping for daily challenges"
  def set_role(guild_id, role_id) do
    update_field(guild_id, :role_to_ping, role_id)
  end

  @doc "Save all config fields at once (for modal submit)"
  def save_all(guild_id, attrs) do
    case Repo.get(__MODULE__, guild_id) do
      nil ->
        # Insert new record
        %__MODULE__{discord_server_id: guild_id}
        |> changeset(attrs)
        |> Repo.insert()

      config ->
        # Update existing record
        config
        |> changeset(attrs)
        |> Repo.update()
    end
  end

  @doc "Get all configured servers (for scheduled tasks)"
  def all_configured do
    from(c in __MODULE__, where: not is_nil(c.aoc_token) and not is_nil(c.aoc_leaderboard_url))
    |> Repo.all()
  end
end
