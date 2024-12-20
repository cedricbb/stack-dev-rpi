.PHONY: logs-all logs-monitoring clean-all clean-logs clean-resources \
clean diagnose deep-analyze generate-report optimize-containers system-check cache-clear

maintenance-help:
	$(call print_title, Commandes de maintenance)
	$(call print_command, logs-all, Affiche les logs de tous les conteneurs)
	$(call print_command, logs-monitoring, Affiche les logs des conteneurs de monitoring)
	$(call print_command, clean-all, Supprime tous les conteneurs et volumes)
	$(call print_command, clean-logs, Supprime les logs)
	$(call print_command, clean-resources, Supprime les ressources inutilisées)
	$(call print_command, diagnose, Diagnostique du système)
	$(call print_command, deep-analyze, Analyse approfondie du système)
	$(call print_command, generate-report, Génération d'un rapport)
	$(call print_command, optimize-containers, Optimisation des containers)
	$(call print_command, system-check, Vérification du système)
	$(call print_command, cache-clear, Nettoyage du cache)
	$(call print_command, daily-check, Vérification quotidienne)
	$(call print_command, weekly-maintenance, Maintenance hebdomadaire)

# Logs
logs-all:
	@docker-compose logs -f

logs-monitoring:
	@docker-compose logs -f portainer prometheus grafana

# Nettoyage
clean-all: down
	@printf "$(_CYAN)Attention: Cette action va supprimer tous les volumes et données$(_END)\n"
	@read -p "Êtes-vous sûr ? [y/N]" confirmation; \
	if [ "$$confirmation" = "y"] || [ "$$confirmation" = "Y" ]; then \
		docker-compose down -v --remove-orphans; \
		rm -rf backups/*; \
		printf "$(_GREEN)Nettoyage complet effectué !$(_END)\n"; \
	else \
		printf "$(_CYAN)Opération annulée$(_END)\n"; \
	fi

clean-logs:
	@printf "$(_CYAN)Suppression des logs...$(_END)\n"
	@find ./logs -type f -not -name "*.log" -exec rm {} \;

clean-resources:
	@printf "$(_CYAN)Suppression des ressources inutilisées...$(_END)\n"
	@docker system prune -a

clean:
	@printf "$(_YELLOW)Attention: Cette action va supprimer tous les containers et volumes$(_END)\n"
	@read -p "Êtes-vous sûr ? [y/N]" confirmation; \
	if [ "$$confirmation" = "y"] || [ "$$confirmation" = "Y" ]; then \
		printf "$(_CYAN)Suppression des containers...$(_END)\n"; \
		$(DOCKER_COMPOSE) down -v --remove-orphans; \
		eho "$(_GREEN)Nettoyage terminé !$(_END)\n"; \
	else \
		printf "$(_CYAN)Opération annulée$(_END)\n"
	fi

# Diagnostic et dépannage
diagnose:
	@printf "$(_CYAN)Diagnostic du système...$(_END)\n"
	@make status
	@make monitor-health
	@make mysql-check
	@make postgres-check
	@printf "$(_GREEN)Diagnostic terminé.$(_END)\n"

deep-analyze:
	@printf "$(_CYAN)Analyse approfondie du système...$(_END)\n"
	@make security-scan
	@make metrics-check
	@docker-compose logs --tail=100
	@printf "$(_GREEN)Analyse terminée.$(_END)\n"

generate-report:
	@printf "$(_CYAN)Génération du rapport...$(_END)\n"
	@mkdir -p reports/${DATE}
	@make diagnose > reports/${DATE}/diagnostics.log
	@make deep-analyze > reports/${DATE}/analysis.log
	@printf "$(_GREEN)Rapport généré dans reports/${DATE}/$(_END)\n"

optimize-containers:
	@printf "$(_CYAN)Optimisation des containers...$(_END)\n"
	@docker system prune -f
	@docker volume prune -f
	@docker-compose up -d --force-recreate --no-deps $(docker-compose ps -q)
	@printf "$(_GREEN)Optimisation terminée.$(_END)\n"

system-check:
	@printf "$(_CYAN)Vérification du système...$(_END)\n"
	@docker system df
	@docker-compose ps
	@df -H
	@free -h
	@printf "$(_GREEN)Vérification terminée.$(_END)\n"

cache-clear:
	@printf "$(_CYAN)Nettoyage du cache...$(_END)\n"
	@docker builder prune -f
	@docker-compose exec redis redis-cli FLUSHALL
	@rm -rf projects/*/tmp/*
	@rm -rf projects/*/cache/*
	@printf "$(_GREEN)Cache nettoyé.$(_END)\n"

# Maintenance périodique
daily-check: monitor-health mysql-check postgres-check

weekly-maintenance: clean-logs optimize-containers backup