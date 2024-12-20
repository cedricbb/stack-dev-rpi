.PHONY: dev-bedrock-install dev-bedrock-setup dev-bedrock-generate-keys dev-bedrock-permissions dev-bedrock-update dev-bedrock-install \
dev-bedrock-composer dev-bedrock-theme dev-bedrock-plugin dev-bedrock-update dev-bedrock

wordpress-help:
	$(call print_title, Commandes Bedrock WordPress)
	$(call print_command, dev-bedrock-install, Installation de Bedrock)
	$(call print_command, dev-bedrock-setup, Configuration de Bedrock)
	$(call print_command, dev-bedrock-generate-keys, Génération des clés Bedrock)
	$(call print_command, dev-bedrock-permissions, Attribution des permissions Bedrock)
	$(call print_command, dev-bedrock-update, Mise à jour de Bedrock)
	$(call print_command, dev-bedrock-composer, Installation d'un package Composer)
	$(call print_command, dev-bedrock-theme, Installation d'un thème)
	$(call print_command, dev-bedrock-plugin, Installation d'un plugin)
	$(call print_command, dev-bedrock-update, Mise à jour de Bedrock)
	$(call print_command, dev-bedrock, Installation des outils de développement WordPress)

dev-bedrock-install:
	@echo "${_CYAN}Installation de Bedrock...${_END}"
	@if [ -d "projects/bedrock" ]; then \
		@echo "${_RED}Le répertoire projects/bedrock existe déjà.${_END}"; \
		exit 1; \
	fi
	@docker-compose run --rm composer create-project roots/bedrock projects/bedrock
	@make bedrock-setup

dev-bedrock-setup:
	@echo "${_CYAN}Configuration de Bedrock...${_END}"
	@if [ ! -f "projects/bedrock/.env" ]; then \
	cp projects/bedrock/.env.example projects/bedrock/.env; \
	fi
	@make bedrock-generate-keys
	@make bedrock-permissions
	@make up

dev-bedrock-generate-keys:
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

dev-bedrock-permissions:
	@echo "${_CYAN}Configuration des permissions Bedrock...${_END}"
	@chmod -R 775 projects/bedrock
	@chmod -R 775 projects/bedrock/web/app/uploads
	@chmod -R 775 projects/bedrock/web/app/cache
	@chmod -R 775 projects/bedrock/web/app/plugins
	@chmod -R 775 projects/bedrock/web/app/themes

dev-bedrock-composer:
	@if [ -z "$(package)" ]; then \
		echo "${_RED}Veuillez spécifier le nom du package à installer.${_END}"; \
		exit 1; \
	fi
	@echo  "${_CYAN}Installation du package Bedrock : $(package)...${_END}"
	@docker-compose run --rm composer composer require $(package)

dev-bedrock-theme:
	@if [ -z "$(theme)" ]; then \
		echo "${_RED}Veuillez spécifier le nom du thème à installer.${_END}"; \
		exit 1; \
	fi
	@echo "${_CYAN}Installation du thème Bedrock : $(theme)...${_END}"
	@docker-compose run --rm composer composer require wpackagist-theme/$(theme)

dev-bedrock-plugin:
	@if [ -z "$(plugin)" ]; then \
		echo "${_RED}Veuillez spécifier le nom du plugin à installer.${_END}"; \
		exit 1; \
	fi
	@echo "${_CYAN}Installation du plugin Bedrock : $(plugin)...${_END}"
	@docker-compose run --rm composer composer require wpackagist-plugin/$(plugin)

dev-bedrock-update:
	@echo "${_CYAN}Mise à jour des dépendances...${_END}"
	@docker-compose run --rm composer composer update

dev-bedrock:
	@echo "${_CYAN}Installation des outils de développement...${_END}"
	@docker-compose run --rm composer composer require --dev \
	roots/wordpress-stubs \
	squizlabs/php_codesniffer \
	dealerdirect/phpcodesniffer-composer-installer \
	wp-coding-standards/wpcs \