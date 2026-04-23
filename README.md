# ⚡ Symfony Starter Kit

A modern, production-ready Symfony 7 starter kit. One command installs everything.

```bash
chmod +x setup.sh && ./setup.sh
```

---

## Requirements

| Tool | Version | Notes |
|---|---|---|
| PHP | 8.3+ | with `pdo_sqlite` extension for local dev |
| Composer | 2.x | [getcomposer.org](https://getcomposer.org) |
| Symfony CLI | optional | for `symfony server:start` |
| Node / npm | optional | AssetMapper doesn't require a build step |

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/your-org/symfony-starter-kit.git my-project
cd my-project

# 2. Run setup (installs deps, migrates DB, seeds data, installs assets)
chmod +x setup.sh && ./setup.sh

# 3. Start the dev server
symfony server:start          # with Symfony CLI
# or
php -S localhost:8000 -t public  # with plain PHP

# 4. Open your browser
open http://localhost:8000
```

**Demo login:** `admin@example.com` / `password`

---

## Laravel Herd Setup

Herd manages PHP versions and serves any PHP project — it is not Laravel-specific.

1. Install [Laravel Herd](https://herd.laravel.com) (macOS / Windows)
2. Add a new site pointing to the **`/public`** folder of this project:
   - Open Herd → Sites → Add site
   - Set **document root** to `<project-path>/public`
3. Run the setup script: `./setup.sh`
4. Visit `http://<site-name>.test` in your browser

> Herd automatically picks up the correct PHP version and handles virtual hosts.

---

## Symfony CLI Setup

```bash
# Install Symfony CLI (macOS)
brew install symfony-cli/tap/symfony-cli

# Install Symfony CLI (Linux)
curl -sS https://get.symfony.com/cli/installer | bash

# Start the dev server with TLS
symfony server:start --no-tls   # HTTP
symfony server:start             # HTTPS (self-signed cert)
```

Visit `http://127.0.0.1:8000` (or the HTTPS URL shown in the terminal).

---

## Make Commands

```bash
make help         # List all available commands

make setup        # Full install (composer, DB, fixtures, assets)
make serve        # Start dev server
make migrate      # Run pending migrations
make migrate-diff # Generate migration from entity changes
make fixtures     # Reload seed data (clears existing)
make db-reset     # Drop, recreate, migrate, and seed

make entity       # Interactive: create/update a Doctrine entity
make controller   # Interactive: create a controller
make form         # Interactive: create a form type

make cache-clear  # Clear Symfony cache
make routes       # List all routes
make services     # List all services
make lint         # Lint Twig and YAML files
make test         # Run PHPUnit
```

---

## Project Structure

```
symfony-starter-kit/
├── assets/
│   ├── app.js              # JS entrypoint (Bootstrap + Alpine.js)
│   └── styles/
│       └── app.css         # CSS custom properties starter
├── bin/
│   └── console             # Symfony console
├── config/
│   ├── bundles.php         # Registered bundles
│   ├── routes.yaml         # Route loading
│   ├── services.yaml       # Service container
│   └── packages/           # Bundle configuration
│       ├── doctrine.yaml
│       ├── framework.yaml
│       ├── security.yaml
│       ├── twig.yaml
│       ├── asset_mapper.yaml
│       └── dev/            # Dev-only config
├── migrations/             # Doctrine migrations
├── public/
│   └── index.php           # Web entry point (document root)
├── src/
│   ├── Controller/         # HTTP controllers
│   ├── DataFixtures/       # Database seeders
│   ├── Entity/             # Doctrine entities
│   ├── EventListener/      # Event subscribers/listeners
│   ├── Form/               # Symfony form types
│   ├── Repository/         # Doctrine repositories
│   ├── Service/            # Business logic services
│   └── Kernel.php
├── templates/
│   ├── base.html.twig      # Base layout
│   ├── components/         # Reusable Twig partials
│   ├── home/
│   │   └── index.html.twig
│   └── security/
│       └── login.html.twig
├── .env.example            # Environment variable reference
├── importmap.php           # AssetMapper: Bootstrap + Alpine.js
├── Makefile
├── setup.sh                # Unix setup script
└── setup.bat               # Windows setup script
```

---

## Database

The default database is **SQLite** — zero config, works instantly.

```
# .env
DATABASE_URL="sqlite:///%kernel.project_dir%/var/data.db"
```

Switch to MySQL or PostgreSQL by editing `.env`:

```bash
# MySQL
DATABASE_URL="mysql://user:pass@127.0.0.1:3306/dbname?serverVersion=8.0&charset=utf8mb4"

# PostgreSQL
DATABASE_URL="postgresql://user:pass@127.0.0.1:5432/dbname?serverVersion=16&charset=utf8"
```

Then recreate the schema:

```bash
make db-reset
```

---

## Creating Entities

```bash
# 1. Generate the entity interactively
make entity
# -> php bin/console make:entity Post

# 2. Generate a migration for the schema change
make migrate-diff
# -> php bin/console doctrine:migrations:diff

# 3. Apply the migration
make migrate
```

### Example entity (attribute-based mapping)

```php
#[ORM\Entity(repositoryClass: PostRepository::class)]
class Post
{
    #[ORM\Id, ORM\GeneratedValue, ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 255)]
    private ?string $title = null;

    #[Gedmo\Timestampable(on: 'create')]
    #[ORM\Column]
    private ?\DateTimeImmutable $createdAt = null;
}
```

---

## Creating Controllers

```bash
make controller
# -> php bin/console make:controller PostController
```

Or manually:

```php
#[Route('/posts', name: 'app_post_')]
class PostController extends AbstractController
{
    #[Route('/', name: 'index')]
    public function index(PostRepository $repo, PaginatorInterface $paginator, Request $request): Response
    {
        $query = $repo->createQueryBuilder('p')->getQuery();
        $posts = $paginator->paginate($query, $request->query->getInt('page', 1), 20);

        return $this->render('post/index.html.twig', ['posts' => $posts]);
    }
}
```

---

## Creating Forms

```bash
make form
# -> php bin/console make:form PostType
```

```php
class PostType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('title', TextType::class)
            ->add('body', TextareaType::class);
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults(['data_class' => Post::class]);
    }
}
```

---

## Frontend (AssetMapper)

Bootstrap 5 and Alpine.js load via native Symfony AssetMapper — **no Node build step required**.

Assets are declared in `importmap.php`. To add a new JS package:

```bash
php bin/console importmap:require lodash
```

To regenerate downloaded assets:

```bash
php bin/console importmap:install
```

Edit `assets/app.js` as your JS entrypoint and `assets/styles/app.css` for global styles.

---

## Authentication

The starter includes a scaffolded login flow:

- `src/Entity/User.php` — implements `UserInterface` + `PasswordAuthenticatedUserInterface`
- `config/packages/security.yaml` — form-login firewall + password hasher
- `src/Controller/SecurityController.php` — login/logout routes
- `templates/security/login.html.twig` — login form

**Demo credentials** (loaded by fixtures): `admin@example.com` / `password`

To add registration, run:

```bash
php bin/console make:registration-form
```

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `APP_ENV` | `dev` | Application environment (`dev`, `prod`, `test`) |
| `APP_SECRET` | auto-generated | Cryptographic secret (generated by `setup.sh`) |
| `DATABASE_URL` | SQLite | Database connection string |
| `MAILER_DSN` | `null://null` | Mailer transport (null discards all emails) |

Copy `.env.example` to `.env` and adjust as needed. Never commit `.env` to version control.

---

## Installed Packages

| Package | Purpose |
|---|---|
| `symfony/framework-bundle` | Core framework |
| `symfony/twig-bundle` + `twig/extra-bundle` | Templating |
| `symfony/doctrine-bundle` + `doctrine/orm` | Database ORM |
| `doctrine/doctrine-migrations-bundle` | Schema migrations |
| `doctrine/doctrine-fixtures-bundle` | Database seeding |
| `fakerphp/faker` | Fake data generation |
| `symfony/security-bundle` | Authentication & authorization |
| `symfony/asset-mapper` | Native asset pipeline |
| `symfony/form` + `symfony/validator` | Forms & validation |
| `symfony/http-client` | HTTP requests |
| `stof/doctrine-extensions-bundle` | Timestampable, Sluggable, etc. |
| `knplabs/knp-paginator-bundle` | Pagination |
| `symfony/maker-bundle` *(dev)* | Code generation |
| `symfony/profiler-pack` *(dev)* | Debug toolbar |
