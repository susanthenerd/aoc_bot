defmodule ChristmasTree do
  def generate(height) do
    # Define the star and trunk using IO.ANSI
    star =
      " " <>
        String.duplicate(" ", height - 1) <> IO.ANSI.yellow() <> "^" <> IO.ANSI.reset() <> "\n"

    trunk = String.duplicate(" ", height - 1) <> IO.ANSI.default_color() <> "|" <> IO.ANSI.reset()

    # Build the tree
    tree =
      Enum.reduce(1..height, star, fn i, acc ->
        spaces = String.duplicate(" ", height - i)

        ornaments =
          for _ <- 1..(2 * i + 1), do: random_color() <> random_letter() <> IO.ANSI.reset()

        acc <> spaces <> Enum.join(ornaments) <> spaces <> "\n"
      end)

    tree <> trunk
  end

  defp random_color do
    Enum.random([
      IO.ANSI.red(),
      IO.ANSI.green(),
      IO.ANSI.yellow(),
      IO.ANSI.blue(),
      IO.ANSI.magenta(),
      IO.ANSI.cyan(),
      IO.ANSI.white()
    ])
  end

  defp random_letter do
    Enum.random(?A..?Z)
    |> to_string()
  end
end
