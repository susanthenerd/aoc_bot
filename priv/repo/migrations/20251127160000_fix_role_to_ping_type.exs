defmodule AocBot.Repo.Migrations.FixRoleToPingType do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE server_configs ALTER COLUMN role_to_ping TYPE bigint USING role_to_ping::bigint"
  end
end
