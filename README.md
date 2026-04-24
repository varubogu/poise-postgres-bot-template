# Poise + PostgreSQL Discord Bot Template

A production-ready Discord bot template built with Rust, featuring clean architecture, PostgreSQL integration, and multi-arch Docker deployment.

## Tech Stack

| Library | Version | Purpose |
|---|---|---|
| [poise](https://github.com/serenity-rs/poise) | 0.6 | Discord bot framework (slash commands, prefix commands) |
| [tokio](https://tokio.rs/) | 1.50 | Async runtime |
| [SeaORM](https://www.sea-ql.org/SeaORM/) | 1.1 | Async ORM for PostgreSQL |
| [sea-orm-migration](https://www.sea-ql.org/SeaORM/docs/migration/setting-up-migration/) | 1.1 | Database schema migrations |
| [tracing](https://docs.rs/tracing) | 0.1 | Structured, leveled logging |
| [thiserror](https://docs.rs/thiserror) | 2.0 | Ergonomic error types |
| [mockall](https://docs.rs/mockall) | 0.14 | Mock objects for unit testing |

## Architecture

This template follows **Clean Architecture** with 4 layers:

```
commands/          ← Presentation layer (Discord slash commands / event handlers)
    ↓
services/          ← Business logic layer
    ↓
repository/        ← Data access interface layer
    ↓
infrastructure/    ← Database, external services implementation
```

**Dependency rule**: outer layers depend on inner layers, never the reverse.

## Quick Start

### Prerequisites

- Rust 1.80+
- Docker & Docker Compose
- A Discord Bot Token ([Discord Developer Portal](https://discord.com/developers/applications))

### Setup

1. **Use this template** (GitHub) or clone:
   ```bash
   git clone https://github.com/your-username/your-bot.git
   cd your-bot
   ```

2. **Configure environment**:
   ```bash
   cp .env.app.example .env.app
   cp .env.db.example .env.db
   ```
   Edit `.env.app` and set your `DISCORD_TOKEN`.

3. **Start the database**:
   ```bash
   docker compose up -d db
   ```

4. **Run the bot**:
   ```bash
   cargo run
   ```
   Migrations run automatically on startup.

### Dev Container (Recommended)

Open in VS Code with the Dev Containers extension. Everything is configured automatically.

## Development

```bash
cargo build          # Build
cargo run            # Run bot (requires .env.app)
cargo test           # Run tests
cargo clippy         # Lint
cargo fmt            # Format

# Database migrations
cargo run -- migrate                                          # Run pending migrations
sea-orm-cli migrate generate migration_name                   # Create new migration
```

## Adding a New Command

1. Create `src/commands/my_command.rs`:
   ```rust
   use crate::{Context, Error};

   #[poise::command(slash_command)]
   pub async fn my_command(ctx: Context<'_>) -> Result<(), Error> {
       ctx.say("Hello!").await?;
       Ok(())
   }
   ```

2. Register in `src/main.rs`:
   ```rust
   commands: vec![commands::ping::ping(), commands::my_command::my_command()],
   ```

## Adding a Database Table

1. Generate a migration:
   ```bash
   sea-orm-cli migrate generate create_my_table
   ```

2. Implement `up` and `down` in `migration/src/m<timestamp>_create_my_table.rs`.

3. Register it in `migration/src/lib.rs`.

4. Generate the entity:
   ```bash
   sea-orm-cli generate entity -u "$DATABASE_URL" -o src/infrastructure/database/entities
   ```

## Database Roles

This template uses two PostgreSQL roles:

| Role | Purpose |
|---|---|
| `app_user` | Application read/write access |
| `admin_user` | Migration execution (full access) |

For production, consider adding Row-Level Security (RLS) to isolate data per guild.

## Deployment

### GitHub Actions

Two workflows are included:

- **CI** (`.github/workflows/ci.yml`): Runs on every push — format check, clippy lint, tests.
- **Deploy** (`.github/workflows/deploy.yml`): Triggered on version tags (`v*.*.*`) — builds multi-arch Docker images and pushes to GHCR.

### Production Deployment

1. Set your `GITHUB_REPOSITORY` (e.g. `your-username/your-bot`) in `.env`:
   ```bash
   export GITHUB_REPOSITORY=your-username/your-bot
   ```

2. Pull and start:
   ```bash
   docker compose pull
   docker compose up -d
   ```

## Project Structure

```
.
├── src/
│   ├── main.rs                      # Bot entry point & framework setup
│   ├── commands/
│   │   └── ping.rs                  # Example slash command
│   ├── errors/
│   │   └── mod.rs                   # AppError type
│   ├── services/                    # Business logic (add your services here)
│   ├── repository/                  # Data access interfaces
│   └── infrastructure/
│       └── database/
│           └── connection.rs        # Database connection setup
├── migration/
│   └── src/
│       ├── lib.rs                   # Migration registry
│       └── m20240101_*.rs           # Example migration
├── db/
│   ├── sh/init.sh                   # DB initialization script
│   └── sql/init.sql                 # Role & database creation SQL
├── locales/
│   └── messages.yml                 # User-facing message strings
├── .devcontainer/                   # Dev Container configuration
├── .github/workflows/               # CI/CD pipelines
├── Dockerfile.app                   # Multi-stage app image
├── Dockerfile.db                    # PostgreSQL image with role setup
└── docker-compose.yml               # Production orchestration
```

## License

MIT
