# Symfony Starter Kit

A modern, lean Symfony 7 starter kit with Vite for asset bundling.

## Requirements

| Tool | Version |
|---|---|
| PHP | 8.3+ (with `pdo_sqlite`) |
| Composer | 2.x |
| Node | 20.19+ or 22.12+ |
| npm | 10+ |

[Laravel Herd](https://herd.laravel.com) (macOS / Windows) handles all of these for you.

## Quick Start

```bash
git clone <repo-url> my-project
cd my-project
composer install                  # PHP deps + .env + DB + migrations + fixtures
npm install && npm run build      # JS deps + asset build
```

That's it. Open the project in your browser:

- **Laravel Herd**: drop the project in your Herd directory and visit `https://<project-name>.test`
- **Symfony CLI**: `symfony server:start`
- **Plain PHP**: `php -S localhost:8000 -t public`

**Demo login:** `admin@example.com` / `password`

## What Composer install does

The `composer install` step automatically runs `php bin/console app:install`, which:

1. Copies `.env.example` to `.env` if missing
2. Generates `APP_SECRET`
3. Creates the SQLite database
4. Runs migrations
5. Loads fixtures (admin user + 10 random users)

This works identically on macOS, Linux, and Windows (PowerShell or Git Bash) — no shell scripts.

## Frontend

Assets are bundled by [Vite](https://vitejs.dev) via [`pentatrion/vite-bundle`](https://symfony-vite.pentatrion.com/).

```bash
npm run dev      # Vite dev server (port 5173) with HMR
npm run build    # Production build → public/build/
```

Edit `assets/app.js` (entrypoint) and `assets/styles/app.css`. Bootstrap 5 and Alpine.js are pre-wired.

To add a JS package:

```bash
npm install some-package
# then import it in assets/app.js
```

## Database

Default is SQLite at `var/data.db`. Switch to MySQL or PostgreSQL by editing `DATABASE_URL` in `.env`:

```
DATABASE_URL="mysql://user:pass@127.0.0.1:3306/dbname?serverVersion=8.0&charset=utf8mb4"
DATABASE_URL="postgresql://user:pass@127.0.0.1:5432/dbname?serverVersion=16&charset=utf8"
```

Then re-run `php bin/console app:install`.

## Make commands

```bash
make help         # List all available commands
make serve        # Start Symfony CLI dev server
make migrate      # Run pending migrations
make migrate-diff # Generate migration from entity changes
make fixtures     # Reload seed data
make db-reset     # Drop, recreate, migrate, seed
make entity       # make:entity
make controller   # make:controller
make cache-clear  # cache:clear
make routes       # debug:router
make lint         # Lint Twig + YAML
make test         # PHPUnit
```

## Project structure

```
.
├── assets/
│   ├── app.js                # Vite entrypoint (Bootstrap + Alpine)
│   └── styles/app.css        # Global styles + design tokens
├── bin/console
├── config/
│   ├── bundles.php
│   ├── packages/             # Bundle config (doctrine, security, twig, vite, ...)
│   ├── routes/               # Route loaders
│   ├── routes.yaml
│   └── services.yaml
├── migrations/               # Doctrine migrations
├── public/
│   ├── build/                # Vite output (git-ignored)
│   └── index.php
├── src/
│   ├── Command/AppInstallCommand.php
│   ├── Controller/
│   ├── DataFixtures/
│   ├── Entity/User.php
│   ├── Repository/
│   └── Kernel.php
├── templates/
├── .env.example
├── composer.json
├── package.json
├── vite.config.js
└── Makefile
```

## Authentication

The starter ships with a working login flow:

- `User` entity with `UserInterface` + `PasswordAuthenticatedUserInterface`
- `form_login` firewall + password hasher (`config/packages/security.yaml`)
- `/login` and `/logout` routes (`SecurityController`)
- Bootstrap-styled login form (`templates/security/login.html.twig`)

Demo credentials are loaded by fixtures: `admin@example.com` / `password`.

## Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `APP_ENV` | `dev` | `dev`, `prod`, or `test` |
| `APP_SECRET` | auto-generated | Cryptographic secret |
| `DATABASE_URL` | SQLite at `var/data.db` | DB connection string |
| `MAILER_DSN` | `null://null` | Mail transport |
