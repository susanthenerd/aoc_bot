defmodule AocBot.Command.Helpers do
  @moduledoc """
  Helper functions for building Discord Message Components v2 responses.

  ## Component Types
  - Container (type 17): Wrapper with accent color
  - Text Display (type 10): Markdown text content
  - Separator (type 14): Visual divider

  ## Example

      respond(interaction, container(0x009900, [
        text("# Hello!"),
        separator(),
        text("Welcome to the bot.")
      ]))
  """

  import Bitwise
  alias Nostrum.Api

  # Flag constants
  @ephemeral 64
  @components_v2 32_768

  @doc """
  Sends an interaction response with Components v2 data.

  Options:
  - `:ephemeral` - Only visible to the user (default: false)
  - `:flags` - Override flags entirely
  """
  def respond(interaction, data, opts \\ []) do
    flags = build_flags(opts)

    response_data =
      data
      |> Map.put(:flags, flags)

    Api.Interaction.create_response(interaction, %{
      type: 4,
      data: response_data
    })
  end

  @doc """
  Sends an ephemeral text response (for errors, confirmations, etc.)
  """
  def respond_ephemeral(interaction, content) do
    Api.Interaction.create_response(interaction, %{
      type: 4,
      data: %{content: content, flags: 64}
    })
  end

  @doc """
  Creates a container component (type 17) with accent color and nested components.
  """
  def container(accent_color, components) when is_list(components) do
    %{
      components: [
        %{
          type: 17,
          accent_color: accent_color,
          components: components
        }
      ]
    }
  end

  @doc """
  Creates a text display component (type 10).
  """
  def text(content) do
    %{type: 10, content: content}
  end

  @doc """
  Creates a separator component (type 14).
  """
  def separator(divider \\ true) do
    %{type: 14, divider: divider}
  end

  @doc """
  Creates an ANSI code block for colored terminal output.
  """
  def ansi_block(content) do
    text("```ansi\n#{content}\n```")
  end

  @doc """
  Sends a channel message with Components v2.

  Options:
  - `:content` - Text content (for mentions, etc.)
  """
  def send_message(channel_id, data, opts \\ []) do
    content = Keyword.get(opts, :content, "")

    Api.Message.create(channel_id,
      content: content,
      components: data.components,
      flags: @components_v2
    )
  end

  defp build_flags(opts) do
    base = @components_v2

    if Keyword.get(opts, :ephemeral, false) do
      base ||| @ephemeral
    else
      Keyword.get(opts, :flags, base)
    end
  end
end
