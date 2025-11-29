defmodule AocBot.Commands.ChristmasTree do
  use AocBot.Command

  @impl AocBot.Command
  def definition, do: %{name: "tree", description: "Display a festive Christmas tree"}

  @impl AocBot.Command
  def execute(interaction) do
    respond(
      interaction,
      container(0x009900, [
        text("# Your Christmas tree is here!"),
        separator(false),
        ansi_block(generate(16))
      ])
    )
  end

  @doc "Generate an ASCII Christmas tree with ANSI colors"
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
end
