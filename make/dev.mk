.PHONY: dev-help dev-npm-install dev-composer-install dev-create-project dev-start \
dev-list-projects dev-php-shell dev-node-shell

dev-help:
	$(call print_title, Commandes de développement)
	$(call print_command, dev-npm-install, Installe les dépendances NPM)
	$(call print_command, dev-composer-install, Installe les dépendances Composer)
	$(call print_command, dev-create-project, Crée un nouveau projet)
	$(call print_command, dev-start, Démarre un projets)
	$(call print_command, dev-list-projects, Liste les projets disponibles)
	$(call print_command, dev-php-shell, Ouvre le shell PHP)
	$(call print_command, dev-node-shell, Ouvre le shell Node)

dev-npm-install:
	@if [ -z "$(project)" ]; then \
		printf "$(_RED)Spécifiez un projet avec project=type/nom_projet$(_END)\n"; \
		exit 1; \
	fi
	@if [ ! -d "projects/$(project)" ]; then \
		printf "$(_RED)Le projet projects/$(project) n'existe pas.$(_END)\n"; \
		exit 1; \
	fi
	@printf "$(_GREEN)Installation des dépendances NPM pour $(project)...$(_END)\n"
	@cd projects/$(project) && npm install

dev-composer-install:
	@if [ -z "$(project)" ]; then \
		printf "$(_RED)Spécifiez un projet avec project=php/nom_projet$(_END)\n"; \
		exit 1; \
	fi
	@if [ ! -d "projects/$(project)" ]; then \
		printf "$(_RED)Le projet projects/$(project) n'existe pas.$(_END)\n"; \
		exit 1; \
	fi
	@printf "$(_GREEN)Installation des dépendances Composer pour $(project)...$(_END)\n"
	@cd projects/$(project) && composer install

dev-create-project:
	@if [ -z "$(type)" ] || [ -z "$(name)"]; then \
		printf "$(_RED)Spécifiez un type et un nom de projet avec type=<type> name=<name>$(_END)\n"; \
		printf "Types disponibles : php, node, react, next, nuxt, angular, flutter, bedrock$(_END)\n"; \
		exit 1; \
	fi
	@printf "$(_CYAN)Création du projet $(type)/$(name)...$(_END)\n"
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
		printf "$(_RED)Type de projet non reconnu.$(_END)\n" && exit 1;; \
	esac

dev-start:
	@if [ -z "$(project)" ]; then \
	printf "$(_RED)Spécifiez un projet avec project=type/nom_projet$(_END)\n"; \
	exit 1; \
	fi
	@printf "$(_CYAN)Lancement de l'environnement $(project)...$(_END)\n"
	@TYPE=$$(printf $(project) | cut -d'/' -f1); \
	NAME=$$(printf $(project) | cut -d'/' -f2); \
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
		printf "$(_RED)Type de projet non reconnu.$(_END)\n" && exit 1;; \
	esac

dev-list-projects:
	@printf "$(_CYAN)Liste des projets disponibles :$(_END)\n"
	@for type in php node react next nuxt angular flutter bedrock; do \
		if [ -d "projects/$$type" ]; then \
			printf "\n${_YELLOW}$$type:$(_END)\n"; \
			ls -1 projects/$$type; \
		fi; \
	done

dev-php-shell:
	@printf "$(_CYAN)Ouverture du shell PHP...$(_END)\n"
	@$(DOCKER_COMPOSE) exec apache-php bash

dev-node-shell:
	@printf "$(_CYAN)Ouverture du shell Node.js...$(_END)\n"
	@$(DOCKER_COMPOSE) exec nodejs bash