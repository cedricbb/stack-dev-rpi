.PHONY: services-help services-up services-down services-restart \
services-status services-logs services-isolate service-recreate

services-help:
	$(call print_title, Commandes de gestion des services)
	$(call print_command, services-up, Démarrer les services)
	$(call print_command, services-down, Arrêter les services)
	$(call print_command, services-restart, Redémarrer les services)
	$(call print_command, services-status, Afficher l'état des services)
	$(call print_command, services-logs, Afficher les logs des services)
	$(call print_command, services-isolate, Isoler un service)
	$(call print_command, service-recreate, Recréer un service)

up:
	@printf "$(_CYAN)Démarrage des services...$(_END)\n"
	docker-compose up -d
	@printf "$(_GREEN)Services démarrés !$(_END)\n"
	@make status

down:
	@printf "$(_CYAN)Arrêt des services...$(_END)\n"
	docker-compose down
	@printf "$(_GREEN)Services Arrêtés !$(_END)\n"

restart:
	@make down
	@make up

status:
	@printf "$(_CYAN)État des services :$(_END)\n"
	docker-compose ps

services-logs:
	@if [ "$(s)" ]; then \
		docker-compose logs -f $(s); \
	else \
		docker-compose log* -f; \
	fi

# Commandes de service
service-isolate:
	@printf "$(_CYAN)Isolation du service $(s)...$(_END)\n"
	docker-compose stop $(s)
	@docker network disconnect backend $(s) || true
	@printf "$(_GREEN)Service isolé.$(_END)\n"

service-recreate:
	@printf "$(_CYAN)Re-création du service $(s)...$(_END)\n"
	docker-compose up -d --force-recreate --no-deps $(s)
	@printf "$(_GREEN)Service re-créé.$(_END)\n"