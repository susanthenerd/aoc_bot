defmodule AocBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc_bot,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AocBot.Application, []}
    ]
  end

  defp deps do
    [
      {:nostrum, "~> 0.8.0"},
      {:jason, "~> 1.4"},
      {:httpoison, "~> 2.2"},
      {:table_rex, "~> 4.0.0"},
      {:quantum, "~> 3.5"},
      {:timex, "~> 3.7"}
    ]
  end
end
