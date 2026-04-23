.PHONY: setup serve migrate fixtures entity controller cache-clear test lint

##
## Symfony Starter Kit
## -------------------
##

setup: ## Full install (composer, assets, DB, fixtures)
	chmod +x setup.sh && ./setup.sh

serve: ## Start the local development server
	@if command -v symfony >/dev/null 2>&1; then \
		symfony server:start; \
	else \
		php -S localhost:8000 -t public; \
	fi

migrate: ## Run pending database migrations
	php bin/console doctrine:migrations:migrate --no-interaction

migrate-diff: ## Generate a migration from entity changes
	php bin/console doctrine:migrations:diff

migrate-status: ## Show migration status
	php bin/console doctrine:migrations:status

fixtures: ## Load database fixtures (WARNING: clears existing data)
	php bin/console doctrine:fixtures:load --no-interaction

db-create: ## Create the database
	php bin/console doctrine:database:create --if-not-exists

db-drop: ## Drop the database (DESTRUCTIVE)
	php bin/console doctrine:database:drop --force

db-reset: db-drop db-create migrate fixtures ## Drop, recreate, migrate and seed

entity: ## Create or update a Doctrine entity (interactive)
	php bin/console make:entity

controller: ## Create a new controller (interactive)
	php bin/console make:controller

form: ## Create a new form type (interactive)
	php bin/console make:form

cache-clear: ## Clear the Symfony cache
	php bin/console cache:clear

cache-warmup: ## Warm up the Symfony cache
	php bin/console cache:warmup

routes: ## List all registered routes
	php bin/console debug:router

services: ## List all registered services
	php bin/console debug:container

test: ## Run PHPUnit tests
	php bin/phpunit

lint: ## Lint Twig templates and YAML config
	php bin/console lint:twig templates/
	php bin/console lint:yaml config/

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
