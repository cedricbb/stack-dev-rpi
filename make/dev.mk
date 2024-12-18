dev-setup:
	@echo "${_CYAN}Configuration de l'environnement de développement...${_END}"
	@mkdir -p projects/{php,node,react,next,nuxt,angular,flutter,bedrock}
	@make npm-install
	@make composer-install

nmp-install:
	@if [ -z "$(project)" ]; then \
		echo "${_RED}Spécifiez un projet avec project=type/nom_projet${_END}"; \
		exit 1; \
	fi
	@if [ ! -d "projects/$(project)" ]; then \
		echo "${_RED}Le projet projects/$(project) n'existe pas.${_END}"; \
		exit 1; \
	fi
	@echo "${_GREEN}Installation des dépendances NPM pour $(project)...${_END}"
	@cd projects/$(project) && npm install

composer-install:
	@if [ -z "$(project)" ]; then \
		echo "${_RED}Spécifiez un projet avec project=php/nom_projet${_END}"; \
		exit 1; \
	fi
	@if [ ! -d "projects/$(project)" ]; then \
		echo "${_RED}Le projet projects/$(project) n'existe pas.${_END}"; \
		exit 1; \
	fi
	@echo "${_GREEN}Installation des dépendances Composer pour $(project)...${_END}"
	@cd projects/$(project) && composer install

create-project:
	@if [ -z "$(type)" ] || [ -z "$(name)"]; then \
		echo "${_RED}Spécifiez un type et un nom de projet avec type=<type> name=<name>${_END}"; \
		echo "Types disponibles : php, node, react, next, nuxt, angular, flutter, bedrock${_END}"; \
		exit 1; \
	fi
	@echo "${_CYAN}Création du projet $(type)/$(name)...${_END}"
	@mkdir -p projects/$(type)/$(name)
	@case $(type) in \
		php) \
			cd projects/php && composer create-project --prefer-dist laravel/laravel $(name);; \
		"node") \
			cd projects/node && npm init -y;; \
		"react") \
			cd projects/react && npx create-react-app $(name);; \
		"next") \
			cd projects/next && npx create-next-app@latest $(name);; \
		"nuxt") \
			cd projects/nuxt && npx nuxi init $(name);; \
		"angular") \
			cd projects/angular && npx @angular/cli new $(name);; \
		"flutter") \
			cd projects/flutter && flutter create $(name);; \
		"bedrock") \
			cd projects/bedrock && composer create-project roots/bedrock $(name);; \
		*) \
		echo "${_RED}Type de projet non reconnu.${_END}" && exit 1;; \
	esac

dev:
	@if [ -z "$(project)" ]; then \
	echo "${_RED}Spécifiez un projet avec project=type/nom_projet${_END}"; \
	exit 1; \
	fi
	@echo "${_CYAN}Lancement de l'environnement $(project)...${_END}"
	@TYPE=$$(echo $(project) | cut -d'/' -f1); \
	NAME=$$(echo $(project) | cut -d'/' -f2); \
	case "$$TYPE" in \
		"php") \
			@docker-compose up -d php-dev-$$NAME;; \
		"node") \
			@docker-compose up -d nodejs-$$NAME;; \
		"react") \
			@docker-compose up -d react-dev-$$NAME;; \
		"next") \
			@docker-compose up -d next-dev-$$NAME;; \
		"nuxt") \
			@docker-compose up -d nuxt-dev-$$NAME;; \
		"angular") \
			@docker-compose up -d angular-dev-$$NAME;; \
		"flutter") \
			@docker-compose up -d flutter-dev-$$NAME;; \
		"bedrock") \
			@docker-compose up -d bedrock-dev-$$NAME;; \
		*) \
		echo "${_RED}Type de projet non reconnu.${_END}" && exit 1;; \
	esac

list-projects:
	@echo "${_CYAN}Liste des projets disponibles :${_END}"
	@for type in php node react next nuxt angular flutter bedrock; do \
		if [ -d "projects/$$type" ]; then \
			echo "\n${_YELLOW}$$type:${_END}"; \
			ls -1 projects/$$type; \
		fi; \
	done

php-shell:
	@echo "${_CYAN}Ouverture du shell PHP...${_END}"
	@$(DOCKER_COMPOSE) exec apache-php bash

node-shell:
	@echo "${_CYAN}Ouverture du shell Node.js...${_END}"
	@$(DOCKER_COMPOSE) exec nodejs bash

bedrock-install:
	@echo "${_CYAN}Installation de Bedrock...${_END}"
	@if [ -d "projects/bedrock" ]; then \
		@echo "${_RED}Le répertoire projects/bedrock existe déjà.${_END}"; \
		exit 1; \
	fi
	@docker-compose run --rm composer create-project roots/bedrock projects/bedrock
	@make bedrock-setup

bedrock-setup:
	@echo "${_CYAN}Configuration de Bedrock...${_END}"
	@if [ ! -f "projects/bedrock/.env" ]; then \
	cp projects/bedrock/.env.example projects/bedrock/.env; \
	fi
	@make bedrock-generate-keys
	@make bedrock-permissions
	@make up

bedrock-generate-keys:
	@echo "${_CYAN}Génération des clés Bedrock...${_END}"
	@docker-compose run --rm composer composer require roots/wp-password-bcrypt
	@echo "AUTH_KEY='$(shell openssl rand -base64 48)'" >> projects/bedrock/.env
	@echo "SECURE_AUTH_KEY='$(shell openssl rand -base64 48)'" >> projects/bedrock/.env
	@echo "LOGGED_IN_KEY='$(shell openssl rand -base64 48)'" >> projects/bedrock/.env
	@echo "NONCE_KEY='$(shell openssl rand -base64 48)'" >> projects/bedrock/.env
	@echo "AUTH_SALT='$(shell openssl rand -base64 48)'" >> projects/bedrock/.env
	@echo "SECURE_AUTH_SALT='$(shell openssl rand -base64 48)'" >> projects/bedrock/.env
	@echo "LOGGED_IN_SALT='$(shell openssl rand -base64 48)'" >> projects/bedrock/.env
	@echo "NONCE_SALT='$(shell openssl rand -base64 48)'" >> projects/bedrock/.env

bedrock-permissions:
	@echo "${_CYAN}Configuration des permissions Bedrock...${_END}"
	@chmod -R 775 projects/bedrock
	@chmod -R 775 projects/bedrock/web/app/uploads
	@chmod -R 775 projects/bedrock/web/app/cache
	@chmod -R 775 projects/bedrock/web/app/plugins
	@chmod -R 775 projects/bedrock/web/app/themes

bedrock-composer:
	@if [ -z "$(package)" ]; then \
		echo "${_RED}Veuillez spécifier le nom du package à installer.${_END}"; \
		exit 1; \
	fi
	@echo  "${_CYAN}Installation du package Bedrock : $(package)...${_END}"
	@docker-compose run --rm composer composer require $(package)

bedrock-theme:
	@if [ -z "$(theme)" ]; then \
		echo "${_RED}Veuillez spécifier le nom du thème à installer.${_END}"; \
		exit 1; \
	fi
	@echo "${_CYAN}Installation du thème Bedrock : $(theme)...${_END}"
	@docker-compose run --rm composer composer require wpackagist-theme/$(theme)

bedrock-plugin:
	@if [ -z "$(plugin)" ]; then \
		echo "${_RED}Veuillez spécifier le nom du plugin à installer.${_END}"; \
		exit 1; \
	fi
	@echo "${_CYAN}Installation du plugin Bedrock : $(plugin)...${_END}"
	@docker-compose run --rm composer composer require wpackagist-plugin/$(plugin)

bedrock-update:
	@echo "${_CYAN}Mise à jour des dépendances...${_END}"
	@docker-compose run --rm composer composer update

bedrock-dev:
	@echo "${_CYAN}Installation des outils de développement...${_END}"
	@docker-compose run --rm composer composer require --dev \
	roots/wordpress-stubs \
	squizlabs/php_codesniffer \
	dealerdirect/phpcodesniffer-composer-installer \
	wp-coding-standards/wpcs \