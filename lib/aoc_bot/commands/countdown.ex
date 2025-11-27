defmodule AocBot.Commands.Countdown do
  use AocBot.Command

  @impl AocBot.Command
  def definition, do: %{name: "countdown", description: "Days until Advent of Code / Christmas"}

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
    end_this_year = Date.new!(year, 12, 25)

    days = Date.diff(end_this_year, today)

    cond do
      days < -4 ->
        days_until_next_year = Date.diff(Date.new!(year + 1, 12, 1), today)

        [
          "The puzzles are solved, and the leaderboard is frozen. Only #{days_until_next_year} days until the next epic code-off!",
          "The party's over, but the hype train rolls on. Recharge for next year's AoC—#{days_until_next_year} days left!",
          "Post-AoC mode: Deploying naps and celebrating triumphs. Next adventure begins in #{days_until_next_year} days!",
          "Another year of puzzles complete! Time to refactor life. Next round begins in #{days_until_next_year} days!",
          "Code, rest, repeat. The countdown to AoC #{year + 1} is already ticking—#{days_until_next_year} days to go!"
        ]
        |> Enum.random()

      days == 0 ->
        [
          "GG! Advent of Code #{year} has reached its final puzzle! Congratulations on all your achievements!",
          "The final star is yours! Reflect, celebrate, and share your triumphs! AoC #{year} is in the books!",
          "Puzzle complete, leaderboard locked, memories made. Advent of Code #{year} ends today—GG!",
          "A legendary journey concludes today. Whether you solved one puzzle or them all, you're a star! GG, Advent of Code #{year}!",
          "It's the end of AoC #{year}, but the beginning of all the stories you'll tell about it. Well played! GG!"
        ]
        |> Enum.random()

      days <= 24 ->
        [
          "Only #{days} days left! I hope you've been nice, because Santa just upgraded his naughty list to a blockchain, and it's immutable!",
          "Christmas countdown engaged! #{days} days until the sleigh launch.",
          "Keep calm and jingle on! Just #{days} more sleeps to go!",
          "Debugging the halls! #{days} days until Christmas!",
          "Santa's running final tests on toys. T-minus #{days} days to Christmas!"
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
