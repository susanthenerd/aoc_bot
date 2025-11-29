defmodule AocBot.Commands.Countdown do
  use AocBot.Command

  @impl AocBot.Command
  def definition, do: %{name: "countdown", description: "Days until Advent of Code ends"}

  @impl AocBot.Command
  def execute(interaction) do
    respond(interaction, container(0x00AAFF, [
      text("# Advent of Code Countdown"),
      separator(),
      text(days_until())
    ]))
  end

  @doc "Get a random countdown message based on current date"
  def days_until do
    today = Date.utc_today()
    {year, _, _} = Date.to_erl(today)
    end_this_year = Date.new!(year, 12, 12)

    days = Date.diff(end_this_year, today)

    cond do
      days < 0 ->
        days_until_next_year = Date.diff(Date.new!(year + 1, 12, 1), today)

        [
          "All 12 puzzles complete! The leaderboard is frozen. Only #{days_until_next_year} days until next year's Advent of Code!",
          "Advent of Code #{year} is wrapped up! Recharge for next year—#{days_until_next_year} days to go!",
          "Post-AoC mode: All 12 days conquered! Next adventure begins in #{days_until_next_year} days!",
          "Another 12 days of puzzles complete! Next round begins in #{days_until_next_year} days!",
          "The 12-day journey is over. Countdown to AoC #{year + 1}: #{days_until_next_year} days!"
        ]
        |> Enum.random()

      days == 0 ->
        [
          "Day 12 of 12! Advent of Code #{year} reaches its grand finale! GG!",
          "The twelfth and final star awaits! AoC #{year} concludes today—make it count!",
          "Puzzle 12 of 12! The last challenge of Advent of Code #{year} is here—GG!",
          "The final day! Whether you solved one puzzle or all twelve, you're a star! GG, AoC #{year}!",
          "It's day 12—the end of AoC #{year}! Finish strong and celebrate! GG!"
        ]
        |> Enum.random()

      days <= 11 ->
        [
          "Day #{12 - days} of 12 complete! Only #{days} days of Advent of Code remaining!",
          "#{days} puzzles to go! Keep those stars coming!",
          "We're on day #{12 - days}—#{days} more chances to shine on the leaderboard!",
          "#{days} days left in Advent of Code #{year}! The countdown continues!",
          "Puzzle #{12 - days} of 12 awaits! Just #{days} more days of coding glory!"
        ]
        |> Enum.random()

      true ->
        days_until_start = Date.diff(Date.new!(year, 12, 1), today)

        [
          "#{days_until_start} days until the code-fueled chaos begins! Prepare for glory!",
          "Only #{days_until_start} days left. Are you ready to debug your way to the stars?",
          "#{days_until_start} days remaining—get hyped, AoC #{year} is going to be epic!",
          "#{days_until_start} days until logic puzzles and leaderboard sprints consume your soul!",
          "Countdown alert: #{days_until_start} days until it's game on. Your stars await!",
          "The gears are turning, the clock is ticking—#{days_until_start} days to go!",
          "#{days_until_start} days to AoC #{year}: The most wonderful debugging time of the year!"
        ]
        |> Enum.random()
    end
  end
end
