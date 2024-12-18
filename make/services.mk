up:
	@echo "${_CYAN}Démarrage des services...${_END}"
	@$(DOCKER_COMPOSE) up -d
	@echo "${_GREEN}Services démarrés !${_END}"
	@make status

down:
	@echo "${_CYAN}Arrêt des services...${_END}"
	@$(DOCKER_COMPOSE) down
	@echo "${_GREEN}Services Arrêtés !${_END}"

restart:
	@make down
	@make up

status:
	@echo "${_CYAN}État des services :${_END}"
	@$(DOCKER_COMPOSE) ps

logs:
	@if [ "$(s)" ]; then \
		$(DOCKER_COMPOSE) logs -f $(s); \
	else \
		$(DOCKER_COMPOSE) log* -f; \
	fi

# Commandes de service
service-isolate:
	@echo "${_CYAN}Isolation du service $(s)...${_END}"
	@docker-compose stop $(s)
	@docker network disconnect backend $(s) || true
	@echo "${_GREEN}Service isolé.${_END}"

recreate:
	@echo "${_CYAN}Re-création du service $(s)...${_END}"
	@docker-compose up -d --force-recreate --no-deps $(s)
	@echo "${_GREEN}Service re-créé.${_END}"