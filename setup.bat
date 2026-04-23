@echo off
setlocal EnableDelayedExpansion

REM ──────────────────────────────────────────────
REM  Symfony Starter Kit — Setup Script (Windows)
REM  Usage: setup.bat
REM ──────────────────────────────────────────────

echo.
echo ════════════════════════════════════════
echo   Symfony Starter Kit — Setup
echo ════════════════════════════════════════
echo.

REM ── 1. Check Requirements ─────────────────────
echo [Checking requirements...]

where php >nul 2>&1
if %errorlevel% neq 0 (
    echo  X  PHP not found. Install PHP 8.3+ from https://php.net or via Laravel Herd.
    exit /b 1
)

for /f "tokens=*" %%v in ('php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;"') do set PHP_VERSION=%%v
echo  OK  PHP !PHP_VERSION!

where composer >nul 2>&1
if %errorlevel% neq 0 (
    echo  X  Composer not found. Install from https://getcomposer.org
    exit /b 1
)
echo  OK  Composer found

set HAS_NODE=false
where npm >nul 2>&1
if %errorlevel% equ 0 (
    set HAS_NODE=true
    for /f "tokens=*" %%v in ('node --version') do echo  OK  Node %%v
)

REM ── 2. Composer install ───────────────────────
echo.
echo [Installing PHP dependencies...]
composer install --no-interaction --prefer-dist --optimize-autoloader
if %errorlevel% neq 0 exit /b %errorlevel%
echo  OK  Composer dependencies installed

REM ── 3. npm install (optional) ─────────────────
if "!HAS_NODE!"=="true" (
    echo.
    echo [Installing Node dependencies...]
    npm install
    if %errorlevel% neq 0 exit /b %errorlevel%
    echo  OK  Node dependencies installed
)

REM ── 4. Copy .env ──────────────────────────────
echo.
echo [Setting up environment...]
if not exist ".env" (
    copy .env.example .env >nul
    echo  OK  Created .env from .env.example
) else (
    echo  ->  .env already exists - skipping copy
)

REM ── 5. Generate APP_SECRET ────────────────────
php -r "
$env = file_get_contents('.env');
if (strpos($env, 'changeme_run_setup_sh_to_generate') !== false) {
    $secret = bin2hex(random_bytes(32));
    $env = preg_replace('/APP_SECRET=.*/', 'APP_SECRET=' . $secret, $env);
    file_put_contents('.env', $env);
    echo ' OK  Generated APP_SECRET' . PHP_EOL;
} else {
    echo ' ->  APP_SECRET already set' . PHP_EOL;
}
"

REM ── 6. Create database ────────────────────────
echo.
echo [Setting up database...]
php bin\console doctrine:database:create --if-not-exists --no-interaction
if %errorlevel% neq 0 exit /b %errorlevel%
echo  OK  Database ready

REM ── 7. Run migrations ─────────────────────────
php bin\console doctrine:migrations:migrate --no-interaction
if %errorlevel% neq 0 exit /b %errorlevel%
echo  OK  Migrations applied

REM ── 8. Load fixtures ──────────────────────────
php bin\console doctrine:fixtures:load --no-interaction
if %errorlevel% neq 0 exit /b %errorlevel%
echo  OK  Fixtures loaded

REM ── 9. Install frontend assets ────────────────
echo.
echo [Installing frontend assets...]
php bin\console importmap:install
echo  OK  AssetMapper assets installed

REM ── 10. Clear cache ───────────────────────────
php bin\console cache:clear --no-interaction
echo  OK  Cache cleared

REM ── Done ──────────────────────────────────────
echo.
echo ════════════════════════════════════════
echo   Setup complete!
echo ════════════════════════════════════════
echo.
echo   Start the dev server:
echo.
echo     With Symfony CLI:   symfony server:start
echo     With plain PHP:     php -S localhost:8000 -t public
echo     With Laravel Herd:  point site root to  %cd%\public
echo.
echo   Useful commands:  make help   (requires GNU Make for Windows)
echo.
endlocal
