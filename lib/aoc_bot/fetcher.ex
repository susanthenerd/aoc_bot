defmodule AocBot.Fetcher do
  use GenServer
  require Logger

  # 15 minutes
  @interval 900_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    state =
      %{data: %{}}
      |> fetch()

    {:ok, state}
  end

  def get_data() do
    GenServer.call(__MODULE__, :get_data)
  end

  defp fetch(state) do
    case fetch_data() do
      {:ok, data} ->
        Logger.info("Fetched data: #{inspect(data)}")
        new_state = %{state | data: data}
        schedule()
        new_state

      {:error, reason} ->
        Logger.error("Failed to fetch data: #{reason}")
        schedule()
        state
    end
  end

  defp schedule() do
    Process.send_after(self(), :fetch, @interval)
  end

  def handle_info(:fetch, state) do
    state = fetch(state)
    {:noreply, state}
  end

  def handle_call(:get_data, _from, state) do
    {:reply, state.data, state}
  end

  defp fetch_data do
    # Ensure you have the proper configuration settings for :aoc_bot
    url = Application.get_env(:aoc_bot, :url)
    cookie = Application.get_env(:aoc_bot, :cookie)

    headers = %{"Cookie" => "session=#{cookie}"}

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} -> {:ok, data}
          {:error, _} = error -> error
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
