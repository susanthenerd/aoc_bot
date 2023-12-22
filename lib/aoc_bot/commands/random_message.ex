defmodule AocBot.Commands.RandomMessage do
  alias Nostrum.Api
  import Nostrum.Struct.Embed

  @messages [
    "🎁 Unboxing joy and don't 🎄 forget to check your code 🌟 twice! 🎁",
    "May your 🔄 loops be merry 🎄 and your code execute ❄️ flawlessly! ⛄",
    "Ho ho ho! 🎅 Santa's found an optimal solution to his 🛷 sleigh loading problem! 🎁",
    "Wishing you a 🥳 heap of happiness and a stack of good 🎉 cheer! 🍾",
    "May your 🐞 bugs be few and your commits be 🎄 merry! 💻",
    "Jingle bells, 🔔 merge conflicts quelled, all is 🌙 calm in the repo tonight! ✨",
    "Rudolph's nose isn't the only thing 🦌 glowing - congrats on lighting up the leaderboard! 💡",
    "Deck the halls with lines of code, 🎶 fa-la-la-la-la, compile, and 🎄 load! 💻",
    "Committing wishes for joy 🎊 and recursion-free holidays! ❄️",
    "While you're waiting for your code to compile, have a 🎅 jolly, jolly Christmas! 🍪",
    "Santa says: 'Array' of gifts 🎁 for everyone! 👨‍💻",
    "Frosty the Snowman says keep your runtime 🌬️ cool! ⛄",
    "Elf-approved code 🧝 coming your way! 💻",
    "Rocking around the Christmas tree 🎸 with Pythonic melodies! 🌲",
    "Sleigh your bugs 🛷 before they sleigh you! 🐜",
    "May your coffee be ☕ strong and your code be bug-free! 🚫",
    "Navigating through the snow 🏃‍♂️ with agile sprints! ❄️",
    "Dashing through the code, in a one-horse open sleigh! 🐎💻",
    "Let's get elf-icient 🧝‍♂️ with our code this season! 💻",
    "Santa's little helper is optimizing your algorithms! 👼🎅"
  ]

  def get_random_message() do
    @messages
    |> Enum.random()
  end

  def run(msg) do
    embed =
      %Nostrum.Struct.Embed{}
      |> put_title("Random Message")
      |> put_color(0x009900)
      |> put_description("#{get_random_message()}")

    Api.create_message(msg.channel_id, embed: embed)
  end
end
