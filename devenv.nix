{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  dotenv.enable = true;

  languages = {
    elixir.enable = true;
    erlang.enable = true;
  };

  services.postgres = {
    enable = true;
    listen_addresses = "127.0.0.1";
    initialDatabases = [ { name = "aoc_bot_dev"; } ];
  };

  processes = {
    app.exec = "mix run --no-halt";
  };

  enterShell = ''
    flyctl completion fish | source

  '';

  containers = {
    aoc-bot = {
      name = "aoc-bot";
      copyToRoot = ./.;
      registry = "docker://registry.fly.io/";
      defaultCopyArgs = [
        "--dest-creds"
        "x:$(${pkgs.flyctl}/bin/flyctl auth token)"
      ];
      # Container entrypoint: setup deps then run app
      entrypoint = [
        "${pkgs.bash}/bin/bash"
        "-c"
        ''
          set -e
          mix local.hex --force --if-missing
          mix local.rebar --force --if-missing
          mix deps.get
          mix deps.compile
          mix compile
          exec mix run --no-halt
        ''
      ];
    };
  };

  packages = lib.optionals (!config.container.isBuilding) [
    pkgs.inotify-tools
    pkgs.flyctl
  ];

  scripts = {
    # Local dev: run setup manually when needed
    setup.exec = ''
      mix local.hex --force --if-missing
      mix local.rebar --force --if-missing
      mix deps.get
      mix deps.compile
      mix compile
    '';

    deploy.exec = ''
      echo "Building and pushing container to fly.io..."
      devenv container aoc-bot --copy
      echo "Deploying to fly.io..."
      flyctl deploy
    '';
  };
}
