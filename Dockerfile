# Use the official Elixir image as a parent image
FROM elixir:1.15

# Set the working directory in the container
WORKDIR /app

# Copy the mix.exs and mix.lock files into the working directory
COPY mix.exs mix.lock ./

# Install hex package manager
RUN mix local.hex --force

# Install rebar (Erlang build tool)
RUN mix local.rebar --force

# Fetch the project dependencies
RUN mix deps.get

# Compile the project dependencies
RUN mix deps.compile

# Copy the rest of your application's code
COPY . .

# Compile the project
RUN mix do compile

# The command to run when the container starts
CMD ["mix", "run", "--no-halt"]
