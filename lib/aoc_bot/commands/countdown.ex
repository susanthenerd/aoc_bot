defmodule AocBot.Commands.Countdown do
  alias Nostrum.Api
  import Nostrum.Struct.Embed

  def days_until_christmas do
    today = Date.utc_today()
    {year, _, _} = Date.to_erl(today)
    christmas_this_year = Date.new!(year, 12, 25)

    days = Date.diff(christmas_this_year, today)

    cond do
      days < -4 ->
        days_until_next_year = Date.diff(Date.new!(year + 1, 12, 1), today)

        post_christmas_messages = [
          "🎄 Christmas is over this year. Only #{days_until_next_year} days until Santa's next wild ride! 🎄",
          "🎄 The elves are on vacation, and Santa's sleigh is in the shop. Back in #{days_until_next_year} days! 🎄",
          "🎄 Holiday mode deactivated. Recharge your cheer! Next Advent of Code in #{days_until_next_year} days! 🎄",
          "🎄 The workshop's closed for a gingerbread break. See you in #{days_until_next_year} days! 🎄",
          "🎄 Santa's gone surfing! Advent of code returns in #{days_until_next_year} days! 🎄"
        ]

        Enum.random(post_christmas_messages)

      days <= 0 ->
        christmas_day_messages = [
          "🎄 Merry Christmas! If you hear a 'Ho Ho Ho,' don't panic. Santa's just running a tad behind schedule! 🎄",
          "🎄 It's Christmas! Check under the tree, the gifts are not virtual this year! 🎄",
          "🎄 May your logs be merry and bright, and may all your code reviews be light! 🎄",
          "🎄 Alert: Increased cookie consumption detected. Merry Christmas! 🎄",
          "🎄 Ho Ho Ho! Decrypting presents now... Merry Christmas! 🎄"
        ]

        Enum.random(christmas_day_messages)

      true ->
        pre_christmas_messages = [
          "🎄 Only #{days} days left! I hope you've been nice, because Santa just upgraded his naughty list to a blockchain, and it's immutable! 🎄",
          "🎄 Christmas countdown engaged! #{days} days until the sleigh launch. 🎄",
          "🎄 Keep calm and jingle on! Just #{days} more sleeps to go! 🎄",
          "🎄 Debugging the halls! #{days} days until Christmas! 🎄",
          "🎄 Santa's running final tests on toys. T-minus #{days} days to Christmas! 🎄"
        ]

        Enum.random(pre_christmas_messages)
    end
  end

  def run(msg) do
    embed =
      %Nostrum.Struct.Embed{}
      |> put_title("Christmas Countdown")
      |> put_color(0x009900)
      |> put_description("#{days_until_christmas()}")

    Api.create_message(msg.channel_id, embed: embed)
  end
end
