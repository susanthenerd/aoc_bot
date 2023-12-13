defmodule AocBot.Application do
  use Application

  def start(_type, _args) do
    children = [
      AocBot.Consumer,
      AocBot.Fetcher
    ]

    opts = [strategy: :one_for_one, name: AocBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
