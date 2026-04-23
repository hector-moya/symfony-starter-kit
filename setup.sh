#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
#  Symfony Starter Kit — Setup Script
#  Usage: chmod +x setup.sh && ./setup.sh
# ──────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo -e "${GREEN}  ✓${RESET} $1"; }
info() { echo -e "${CYAN}  →${RESET} $1"; }
warn() { echo -e "${YELLOW}  ⚠${RESET} $1"; }
fail() { echo -e "${RED}  ✗${RESET} $1"; exit 1; }
header() { echo -e "\n${BOLD}${CYAN}$1${RESET}"; }

# ── 1. Check Requirements ──────────────────────
header "Checking requirements..."

# PHP
if ! command -v php &>/dev/null; then
    fail "PHP is not installed. Install PHP 8.3+ from https://php.net or via Laravel Herd."
fi

PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_MAJOR=$(php -r "echo PHP_MAJOR_VERSION;")
PHP_MINOR=$(php -r "echo PHP_MINOR_VERSION;")

if [ "$PHP_MAJOR" -lt 8 ] || { [ "$PHP_MAJOR" -eq 8 ] && [ "$PHP_MINOR" -lt 3 ]; }; then
    fail "PHP 8.3+ is required. Current version: $PHP_VERSION"
fi
ok "PHP $PHP_VERSION"

# Composer
if ! command -v composer &>/dev/null; then
    fail "Composer is not installed. Install from https://getcomposer.org"
fi
ok "Composer $(composer --version --no-ansi 2>/dev/null | head -1 | awk '{print $3}')"

# Node / npm (optional)
HAS_NODE=false
if command -v node &>/dev/null && command -v npm &>/dev/null; then
    HAS_NODE=true
    ok "Node $(node --version) / npm $(npm --version)"
else
    warn "Node/npm not found — skipping npm install (AssetMapper doesn't require it)"
fi

# SQLite extension (needed for default DATABASE_URL)
if ! php -r "new PDO('sqlite::memory:');" &>/dev/null; then
    warn "PHP SQLite extension (pdo_sqlite) not found. You may need to switch DATABASE_URL to MySQL/PostgreSQL."
fi

# ── 2. Composer install ───────────────────────
header "Installing PHP dependencies..."
composer install --no-interaction --prefer-dist --optimize-autoloader
ok "Composer dependencies installed"

# ── 3. npm install (optional) ─────────────────
if [ "$HAS_NODE" = true ]; then
    header "Installing Node dependencies..."
    npm install
    ok "Node dependencies installed"
fi

# ── 4. Copy .env ──────────────────────────────
header "Setting up environment..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    ok "Created .env from .env.example"
else
    info ".env already exists — skipping copy"
fi

# ── 5. Generate APP_SECRET ────────────────────
if grep -q "changeme_run_setup_sh_to_generate" .env; then
    if command -v openssl &>/dev/null; then
        SECRET=$(openssl rand -hex 32)
    else
        SECRET=$(php -r "echo bin2hex(random_bytes(32));")
    fi
    # Portable sed: handle both macOS (BSD) and Linux (GNU)
    if sed --version 2>&1 | grep -q GNU; then
        sed -i "s/APP_SECRET=.*/APP_SECRET=${SECRET}/" .env
    else
        sed -i '' "s/APP_SECRET=.*/APP_SECRET=${SECRET}/" .env
    fi
    ok "Generated APP_SECRET"
else
    info "APP_SECRET already set — skipping"
fi

# ── 6. Create database ────────────────────────
header "Setting up database..."
# doctrine:database:create is a no-op for SQLite (the file is auto-created on
# first connection), but it's needed for MySQL/PostgreSQL. Ignore the error
# produced by SQLite's lack of listDatabases support.
php bin/console doctrine:database:create --if-not-exists --no-interaction 2>/dev/null || true
ok "Database ready"

# ── 7. Run migrations ─────────────────────────
info "Running migrations..."
php bin/console doctrine:migrations:migrate --no-interaction
ok "Migrations applied"

# ── 8. Load fixtures ──────────────────────────
info "Loading fixtures (seed data)..."
php bin/console doctrine:fixtures:load --no-interaction
ok "Fixtures loaded"

# ── 9. Install frontend assets ────────────────
header "Installing frontend assets..."
php bin/console importmap:install
ok "AssetMapper assets installed"

# ── 10. Clear cache ───────────────────────────
php bin/console cache:clear --no-interaction
ok "Cache cleared"

# ── Done ──────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}  Setup complete!${RESET}"
echo -e "${BOLD}${GREEN}════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${BOLD}Start the dev server:${RESET}"
echo ""
echo -e "    ${CYAN}# With Symfony CLI${RESET}"
echo -e "    symfony server:start"
echo ""
echo -e "    ${CYAN}# With plain PHP${RESET}"
echo -e "    php -S localhost:8000 -t public"
echo ""
echo -e "    ${CYAN}# With Laravel Herd — point your site root to:${RESET}"
echo -e "    $(pwd)/public"
echo ""
echo -e "  ${BOLD}Useful commands:${RESET}  make help"
echo ""
