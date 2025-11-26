defmodule AocBot.Fetcher do
  @moduledoc """
  Fetches Advent of Code leaderboard data on-demand with per-guild caching.
  Uses ETS for caching with a 15-minute TTL.
  """

  require Logger

  @cache_table :aoc_fetcher_cache
  @cache_ttl_seconds 900  # 15 minutes

  @doc "Initialize the ETS cache table. Called from Application."
  def init_cache do
    :ets.new(@cache_table, [:set, :public, :named_table])
    :ok
  end

  @doc """
  Get leaderboard data for a guild. Returns cached data if fresh, otherwise fetches.
  Returns {:ok, data} or {:error, reason}
  """
  def get_data(guild_id) do
    case get_cached(guild_id) do
      {:ok, data} ->
        Logger.debug("Using cached data for guild #{guild_id}")
        {:ok, data}

      :miss ->
        Logger.info("Cache miss for guild #{guild_id}, fetching fresh data")
        fetch_and_cache(guild_id)
    end
  end

  @doc "Force refresh data for a guild, ignoring cache"
  def refresh(guild_id) do
    fetch_and_cache(guild_id)
  end

  @doc "Get the last fetch time for a guild"
  def get_last_fetch_time(guild_id) do
    case :ets.lookup(@cache_table, guild_id) do
      [{^guild_id, _data, timestamp}] -> timestamp
      [] -> nil
    end
  end

  @doc "Clear cache for a guild"
  def clear_cache(guild_id) do
    :ets.delete(@cache_table, guild_id)
    :ok
  end

  # Private functions

  defp get_cached(guild_id) do
    case :ets.lookup(@cache_table, guild_id) do
      [{^guild_id, data, timestamp}] ->
        age = DateTime.diff(DateTime.utc_now(), timestamp, :second)
        if age < @cache_ttl_seconds do
          {:ok, data}
        else
          :miss
        end

      [] ->
        :miss
    end
  end

  defp fetch_and_cache(guild_id) do
    with {:ok, config} <- AocBot.ServerConfig.get(guild_id),
         :ok <- validate_config(config),
         {:ok, data} <- fetch_from_aoc(config.aoc_leaderboard_url, config.aoc_token) do
      timestamp = DateTime.utc_now()
      :ets.insert(@cache_table, {guild_id, data, timestamp})
      {:ok, data}
    end
  end

  defp validate_config(config) do
    cond do
      is_nil(config.aoc_token) ->
        {:error, :token_not_set}

      is_nil(config.aoc_leaderboard_url) ->
        {:error, :leaderboard_not_set}

      true ->
        :ok
    end
  end

  defp fetch_from_aoc(url, token) do
    json_url = ensure_json_url(url)
    headers = [{"Cookie", "session=#{token}"}]

    Logger.debug("Fetching AOC data from #{json_url}")

    case HTTPoison.get(json_url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %HTTPoison.Response{status_code: 400}} ->
        {:error, :invalid_token}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :leaderboard_not_found}

      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, {:http_error, status}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, {:network_error, reason}}
    end
  end

  # Ensure URL ends with .json
  defp ensure_json_url(url) do
    url = String.trim_trailing(url, "/")
    if String.ends_with?(url, ".json") do
      url
    else
      url <> ".json"
    end
  end
end
