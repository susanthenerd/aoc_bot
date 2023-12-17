defmodule AocBot.Fetcher do
  @moduledoc """
  This module is responsible for fetching data from the API at regular intervals.
  It uses GenServer to manage its state and schedule fetch operations.
  """

  use GenServer
  require Logger

  @interval 900

  defstruct data: %{}, last_fetch: DateTime.utc_now(), auto_fetch: false

  @type t :: %__MODULE__{
          data: map(),
          last_fetch: DateTime.t(),
          auto_fetch: boolean()
        }

  @type gen_server_response :: {:ok, t, {:continue, :fetch}} | {:ok, t}

  @doc """
  Starts the GenServer with the given arguments.
  """
  @spec start_link(list()) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Initializes the GenServer state.
  """
  @spec init(any()) :: gen_server_response()
  def init(_) do
    {:ok,
     %{
       data: %{},
       last_fetch: DateTime.add(DateTime.utc_now(), -@interval, :second),
       auto_fetch: false
     }, {:continue, :fetch}}
  end

  @doc """
  Retrieves the fetched data.
  """
  @spec get_data() :: any()
  def get_data(), do: GenServer.call(__MODULE__, :get_data)

  @doc """
  Enables automatic fetching.
  """
  @spec enable_auto_fetch() :: :ok
  def enable_auto_fetch(), do: GenServer.call(__MODULE__, :enable_auto_fetch)

  @doc """
  Disables automatic fetching.
  """
  @spec disable_auto_fetch() :: :ok
  def disable_auto_fetch(), do: GenServer.call(__MODULE__, :disable_auto_fetch)

  @doc """
  Retrieves the state of automatic fetching.
  """
  @spec get_auto_fetch_state() :: boolean()
  def get_auto_fetch_state(), do: GenServer.call(__MODULE__, :get_auto_fetch_state)

  @doc """
  Retrieves the time of the last fetch operation.
  """
  @spec get_last_fetch_time() :: DateTime.t()
  def get_last_fetch_time(), do: GenServer.call(__MODULE__, :get_last_fetch_time)

  def handle_continue(:fetch, state), do: {:noreply, fetch(state)}
  def handle_info(:fetch, state), do: {:noreply, fetch(state)}
  def handle_info(:auto_fetch, state), do: {:noreply, handle_auto_fetch(state)}

  def handle_call(:get_data, _from, state) do
    new_state = fetch(state)
    {:reply, new_state.data, new_state}
  end

  def handle_call(:enable_auto_fetch, _from, state), do: {:reply, :ok, enable_auto_fetch(state)}

  def handle_call(:disable_auto_fetch, _from, state),
    do: {:reply, :ok, %{state | auto_fetch: false}}

  def handle_call(:get_auto_fetch_state, _from, state), do: {:reply, state.auto_fetch, state}
  def handle_call(:get_last_fetch_time, _from, state), do: {:reply, state.last_fetch, state}

  defp fetch(state) do
    if DateTime.diff(DateTime.utc_now(), state.last_fetch, :second) >= @interval do
      perform_fetch(state)
    else
      Logger.info("Using cached data")
      state
    end
  end

  defp perform_fetch(state) do
    with {:ok, data} <- fetch_data() do
      Logger.debug(data)
      %{state | data: data, last_fetch: DateTime.utc_now()}
    else
      _ -> schedule_fetch(state)
    end
  end

  defp schedule_fetch(state) do
    Process.send_after(self(), :fetch, @interval)
    state
  end

  defp handle_auto_fetch(state) do
    if state.auto_fetch do
      fetch(state)
      |> schedule_fetch()
    else
      Logger.info("Auto-fetch is now disabled. Skipping fetch.")
      state
    end
  end

  defp enable_auto_fetch(state) do
    fetch(state)
    |> schedule_fetch()
    |> Map.put(:auto_fetch, true)
  end

  defp fetch_data do
    url = Application.get_env(:aoc_bot, :url)
    cookie = Application.get_env(:aoc_bot, :cookie)

    headers = %{"Cookie" => "session=#{cookie}"}

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.debug(body)
        Jason.decode(body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
