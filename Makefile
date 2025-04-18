SHELL = /bin/bash
API_DIR := api

# Get the system architecture value
ARCH_VALUE := $(shell uname -m)

# Replace x86_64 architecture value to the amd64
ifeq ($(ARCH_VALUE),x86_64)
ARCH_VALUE := amd64
endif

# Set valid linux architecture for docker images
export DOCKER_DEFAULT_PLATFORM=linux/$(ARCH_VALUE)

export UID=$(shell id -u)
export GID=$(shell id -g)

# Load app variables by ENV (env extend default file)
-include $(API_DIR)/.env
-include $(API_DIR)/.env.local
-include $(API_DIR)/.env.dev
-include $(API_DIR)/.env.prod
export

# Default docker compose values (or get exists)
REGISTRY  ?= localhost
IMAGE_TAG ?= latest
APP_ENV   ?= local

DOCKER_COMPOSE_OPTIONS   := -f compose.yml -f compose.override.yml
DOCKER_COMPOSE           := docker compose $(DOCKER_COMPOSE_OPTIONS)
DOCKER_BAKE              := docker buildx bake --file docker-bake.hcl
PHP                      := $(DOCKER_COMPOSE) run --rm api-php-cli php
PHP_CONTAINER_SHELL      := $(DOCKER_COMPOSE) run --rm api-php-cli
COMPOSER_BIN             := $(DOCKER_COMPOSE) run --rm api-php-cli composer
BIN_CONSOLE              := $(PHP) bin/console
DOCKER_CONTAINER_API_DIR := docker run --rm -v $(PWD)/$(API_DIR):/app -w /app # required docker image name, volume to api dir

init: ## Run app
	@make down \
		api-clear \
 		build up
.PHONY: init

prepare: ## Init common configs
	@echo 'APP_SECRET=99eaebf0b00eab05c0042c16fe4f71ce' > $(API_DIR)/.env.local
	@echo 'APP_DEBUG=1' >> $(API_DIR)/.env.local
.PHONY: prepare

vendor: ## Install all dependencies
	$(COMPOSER_BIN) install --prefer-dist --no-progress --optimize-autoloader
.PHONY: vendor

##
## Docker commands
## ------

up: ## Run docker app
	$(DOCKER_COMPOSE) up --build --remove-orphans --detach
.PHONY: up

down: ## Stop docker app
	$(DOCKER_COMPOSE) down --remove-orphans
.PHONY: stop

down-clear: ## Docker down, remove old containers, remove volumes
	$(DOCKER_COMPOSE) down -v --remove-orphans
.PHONY: down-clear

down-and-remove-all-containers: ## Stop and remove every container
	docker stop $$(docker ps -qa)
	docker rm $$(docker ps -qa)
.PHONY: down-and-remove-all-containers

build: ## Build docker images
	$(DOCKER_BAKE) $(APP_ENV)
.PHONY: build

build-no-cache: ## Build docker images
	USE_DOCKER_CACHE=0 $(DOCKER_BAKE) $(APP_ENV)
.PHONY: build-no-cache

logs: ## Print docker compose logs
	$(DOCKER_COMPOSE) logs
.PHONY: logs

generate-basic-auth: ## Generate a HTTP Basic Authentication credentials file in the following format: some_name.htpasswd
	@DEFAULT_BASIC_AUTH_FILENAME=main; \
	DEFAULT_BASIC_AUTH_EXT=htpasswd; \
	CONFIG_DIR=./docker/gateway/config;\
	read -p "Enter basic auth filename [$${DEFAULT_BASIC_AUTH_FILENAME}.$${DEFAULT_BASIC_AUTH_EXT})]: " BASIC_AUTH_FILENAME; \
	read -p "Enter username: " AUTH_USERNAME; \
    read -p "Enter password: " AUTH_PASSWORD; \
	export NEW_BASIC_AUTH_FILENAME=$${BASIC_AUTH_FILENAME:-$${DEFAULT_BASIC_AUTH_FILENAME}}.$${DEFAULT_BASIC_AUTH_EXT}; \
	export AUTH_USERNAME AUTH_PASSWORD; \
	docker run --rm --entrypoint htpasswd httpd:2 -Bbn $${AUTH_USERNAME} $${AUTH_PASSWORD} > $$CONFIG_DIR/$${NEW_BASIC_AUTH_FILENAME}; \
	echo "File '$$CONFIG_DIR/$${NEW_BASIC_AUTH_FILENAME}' created with credentials: $${AUTH_USERNAME}:$${AUTH_PASSWORD}"
.PHONY: generate-basic-auth

composer-container-interactive: ## Run composer:lastest docker container interactive
	$(DOCKER_CONTAINER_API_DIR) -it composer:latest /bin/bash
.PHONY: composer-container-interactive

##
## API commands
## ------

api-cli: ## Run interactive php-cli container
	$(PHP_CONTAINER_SHELL) /bin/bash
.PHONY: api-cli

api-clear: ## Delete all items except with '.' in start
	$(DOCKER_CONTAINER_API_DIR) alpine sh -c 'rm -rf var/cache/* var/cache/.*.cache var/log/* var/test/* '
.PHONY: api-clear

##
## Api Dependencies
## ------

composer-update: ## Update api dependencies
	$(COMPOSER_BIN) update
	$(COMPOSER_BIN) bump
.PHONY: composer-update

composer-dump: ## Update composer autoload file
	$(COMPOSER_BIN) dump-autoload
.PHONY: composer-dump

composer-require: ## Add dependencies
	@read -p "Dependencies: " COMPOSE_DEPENDENCIES && $(COMPOSER_BIN) require $${COMPOSE_DEPENDENCIES}
.PHONY: composer-require

composer-require-dev: ## add dev dependencies
	@read -p "Dependencies: " COMPOSE_DEPENDENCIES && $(COMPOSER_BIN) require --dev $${COMPOSE_DEPENDENCIES}
.PHONY: composer-require-dev

##
## Code quality
## ------

composer-validate: ## Check composer.json and composer.lock with composer validate (https://getcomposer.org/doc/03-cli.md#validate)
	$(COMPOSER_BIN) validate --strict --no-check-publish
.PHONY: composer-validate
