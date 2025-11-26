defmodule AocBot.Commands.ChristmasTree do
  import Nostrum.Struct.Embed
  require Logger

  def generate(height) do
    star =
      String.duplicate(" ", height - 1) <>
        IO.ANSI.yellow() <> "^" <> IO.ANSI.reset() <> "\n"

    trunk =
      String.duplicate(" ", height - 2) <>
        IO.ANSI.yellow() <> "|||" <> IO.ANSI.reset() <> "\n"

    tree =
      Enum.reduce(1..height, star, fn i, acc ->
        spaces = String.duplicate(" ", height - i)
        leaf_count = i * 2 - 1

        leaves =
          for _ <- 1..leaf_count do
            if Enum.random(1..5) == 1 do
              random_color() <> Enum.random(["@", "&", "$", "*"]) <> IO.ANSI.reset()
            else
              IO.ANSI.green() <> Enum.random(["<", ">"]) <> IO.ANSI.reset()
            end
          end

        acc <> spaces <> Enum.join(leaves) <> spaces <> "\n"
      end)

    tree <> trunk <> trunk
  end

  defp random_color do
    Enum.random([
      IO.ANSI.red(),
      IO.ANSI.blue(),
      IO.ANSI.cyan(),
      IO.ANSI.magenta()
    ])
  end

  def embed do
    %{
      flags: 32_768,
      components: [
        %{
          # CONTAINER
          type: 17,
          accent_color: 0x009900,
          components: [
            %{
              # TEXT_DISPLAY
              type: 10,
              content: "# Your Christmas tree is here!"
            },
            %{
              # SEPARATOR
              type: 14,
              divider: false
            },
            %{
              # TEXT_DISPLAY
              type: 10,
              content: """
              ```ansi
              #{generate(15)}
              ```
              """
            }
          ]
        }
      ]
    }
  end
end
