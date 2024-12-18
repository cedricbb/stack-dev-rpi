# Logs
logs-all:
	@docker-compose logs -f

logs-monitoring:
	@docker-compose logs -f portainer prometheus grafana

# Nettoyage
clean-all: down
	@echo "${_CYAN}Attention: Cette action va supprimer tous les volumes et données${_END}"
	@read -p "Êtes-vous sûr ? [y/N]" confirmation; \
	if [ "$$confirmation" = "y"] || [ "$$confirmation" = "Y" ]; then \
		docker-compose down -v --remove-orphans; \
		rm -rf backups/*; \
		echo "${_GREEN}Nettoyage complet effectué !${_END}"; \
	else \
		echo "${_CYAN}Opération annulée${_END}"; \
	fi

clean-logs:
	@echo "${_CYAN}Suppression des logs...${_END}"
	@find ./logs -type f -not -name "*.log" -exec rm {} \;

clean-resources:
	@echo "${_CYAN}Suppression des ressources inutilisées...${_END}"
	@docker system prune -a

optimize-containers:
	@echo "${_CYAN}Optimisation des containers...${_END}"
	@docker-compose up -d --force-recreate --no-deps ${docker-compose ps -q}

clean:
	@echo "${-_YELLOW}Attention: Cette action va supprimer tous les containers et volumes${_END}"
	@read -p "Êtes-vous sûr ? [y/N]" confirmation; \
	if [ "$$confirmation" = "y"] || [ "$$confirmation" = "Y" ]; then \
		echo "${_CYAN}Suppression des containers...${_END}"; \
		$(DOCKER_COMPOSE) down -v --remove-orphans; \
		eho "${_GREEN}Nettoyage terminé !${_END}"; \
	else \
		echo "${_CYAN}Opération annulée${_END}"
	fi

# Diagnostic et dépannage
diagnose:
	@echo "${_CYAN}Diagnostic du système...${_END}"
	@make status
	@make monitor-health
	@make mysql-check
	@make postgres-check
	@echo "${_GREEN}Diagnostic terminé.${_END}"

deep-analyze:
	@echo "${_CYAN}Analyse approfondie du système...${_END}"
	@make security-scan
	@make metrics-check
	@docker-compose logs --tail=100
	@echo "${_GREEN}Analyse terminée.${_END}"

generate-report:
	@echo "${_CYAN}Génération du rapport...${_END}"
	@mkdir -p reports/${DATE}
	@make diagnose > reports/${DATE}/diagnostics.log
	@make deep-analyze > reports/${DATE}/analysis.log
	@echo "${_GREEN}Rapport généré dans reports/${DATE}/${_END}"

optimize-containers:
	@echo "${_CYAN}Optimisation des containers...${_END}"
	@docker system prune -f
	@docker volume prune -f
	@docker-compose up -d --force-recreate --no-deps $(docker-compose ps -q)
	@echo "${_GREEN}Optimisation terminée.${_END}"

system-check:
	@echo "${_CYAN}Vérification du système...${_END}"
	@docker system df
	@docker-compose ps
	@df -H
	@free -h
	@echo "${_GREEN}Vérification terminée.${_END}"

cache-clear:
	@echo "${_CYAN}Nettoyage du cache...${_END}"
	@docker builder prune -f
	@docker-compose exec redis redis-cli FLUSHALL
	@rm -rf projects/*/tmp/*
	@rm -rf projects/*/cache/*
	@echo "${_GREEN}Cache nettoyé.${_END}"

# Maintenance périodique
daily-check: monitor-health mysql-check postgres-check

weekly-maintenance: clean-logs optimize-containers backup