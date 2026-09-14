---
name: ecto-release-migrations
description: "Set up database migrations for Elixir releases. Use when asked to configure release migrations, add migrate command to releases, or set up Ecto for production deployment without Mix."
---

# Ecto Release Migrations Setup

## Overview
In Elixir releases, Mix is not available. This skill creates a Release module that handles database creation, migration, and rollback via `bin/app_name eval` commands.

## Workflow

1. **Detect app name and repos**
   - Check `mix.exs` for app name
   - Check `config/config.exs` or `config/runtime.exs` for Ecto repos

2. **Create Release module**
   - Location: `lib/<app_name>/release.ex`
   - Must handle multiple repos if present

3. **Verify config**
   - Ensure `config/runtime.exs` has production database config
   - Check for `DATABASE_URL` or explicit config

## Implementation

### Release Module Template
```elixir
defmodule <AppName>.Release do
  @moduledoc """
  Release tasks for database management.
  
  Usage in production:
    bin/<app_name> eval "<AppName>.Release.migrate()"
    bin/<app_name> eval "<AppName>.Release.rollback(<AppName>.Repo, 20240101000000)"
  """

  @app :<app_name>

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def create do
    load_app()

    for repo <- repos() do
      case repo.__adapter__().storage_up(repo.config()) do
        :ok -> IO.puts("Database created for #{inspect(repo)}")
        {:error, :already_up} -> IO.puts("Database already exists for #{inspect(repo)}")
        {:error, term} -> raise "Failed to create database: #{inspect(term)}"
      end
    end
  end

  def seed do
    load_app()
    
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn _repo ->
        seed_file = Application.app_dir(@app, "priv/repo/seeds.exs")
        if File.exists?(seed_file) do
          Code.eval_file(seed_file)
        end
      end)
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.ensure_all_started(:ssl)
    Application.load(@app)
  end
end
```

### For Phoenix Projects with Multiple Repos

If multiple repos exist (e.g., `Repo` and `ReadRepo`), ensure `config.exs` has:
```elixir
config :<app_name>, ecto_repos: [<AppName>.Repo, <AppName>.ReadRepo]
```

## Verification Steps

After creating the module:

1. Compile: `mix compile`
2. Test locally: `mix run -e "<AppName>.Release.migrate()"`
3. Build release: `MIX_ENV=prod mix release`
4. Test release: `_build/prod/rel/<app_name>/bin/<app_name> eval "<AppName>.Release.migrate()"`

## Usage Documentation

Add to project README or deployment docs:
```bash
# Create database (first deploy only)
bin/<app_name> eval "<AppName>.Release.migrate()"

# Run migrations
bin/<app_name> eval "<AppName>.Release.migrate()"

# Rollback to specific version
bin/<app_name> eval "<AppName>.Release.rollback(<AppName>.Repo, 20240101000000)"

# Seed database
bin/<app_name> eval "<AppName>.Release.seed()"
```

## Common Issues

- **SSL not started**: Ensure `Application.ensure_all_started(:ssl)` is called before repo operations
- **App not loaded**: Always call `Application.load(@app)` first
- **Missing ecto_repos config**: Verify `config :app_name, ecto_repos: [...]` exists
