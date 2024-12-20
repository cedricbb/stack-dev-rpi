.PHONY: monitoring-setup monitoring-status monitoring-health monitoring-resources \
monitoring-alert-test monitoring-stats monitoring-metrics-check monitoring-check-logs \
monitoring-grafana-check monitoring-grafana-backup

monitoring-help:
	$(call print_title, Commandes de gestion du monitoring)
	$(call print_command, monitoring-setup, Configuration du monitoring)
	$(call print_command, monitoring-status, État des services de monitoring)
	$(call print_command, monitoring-health, Vérification de l'état des services)
	$(call print_command, monitoring-resources, Surveillance des ressources)
	$(call print_command, monitoring-alert-test, Test des alertes)
	$(call print_command, monitoring-stats, Statistiques système)
	$(call print_command, monitoring-metrics-check, Vérification des métriques)
	$(call print_command, monitoring-check-logs, Vérification des logs)
	$(call print_command, monitoring-grafana-check, Vérification de Grafana)
	$(call print_command, monitoring-grafana-backup, Sauvegarde de Grafana)

monitoring-setup:
	@printf "$(_CYAN)Configuration du monitoring...$(_END)\n"
	@docker-compose up -d prometheus grafana alertmanager portainer
	@mkdir -p config/grafana/dashboards
	@cp config/grafana/default/*.json config/grafana/dashboards/
	@docker-compose restart grafana
	@printf "$(_GREEN)Monitoring configuré.$(_END)\n"

monitoring-status:
	@printf "$(_CYAN)État des services de monitoring :$(_END)\n"
	@docker-compose ps portainer prometheus grafana

monitoring-health:
	@printf "$(_CYAN)Vérification de l'état des services...$(_END)\n"
	@docker-compose ps -a
	@printf "\nContainer Resource Usage:"
	@docker stats --no-stream

monitoring-resources:
	@printf "$(_CYAN)Surveillance des ressources...$(_END)\n"
	@docker stats --no-stream
	@printf "\nUtilisation disque:"
	@df -h
	@printf "\nUtilisation mémoire :"
	@free -h

monitoring-alert-test:
	@printf "$(_CYAN)Test d'alerte...$(_END)\n"
	@curl -X POST -H "http://alertmanager:9093/api/v1/alerts" -d '[{"labels":{"alertname":"TestAlert","severity":"info"},"annotations":{"summary":"Alerte de test"}}]'

monitoring-stats:
	@printf "$(_CYAN)Statistiques système...$(_END)\n"
	@docker-compose exec prometheus promtool query instant 'container_memory_usage_bytes'
	@docker-compose exec prometheus promtool query instant 'container_cpu_usage_seconds_total'

monitoring-metrics-check:
	@printf "$(_CYAN)Vérification des métriques...$(_END)\n"
	@curl -s http://localhost:9090/-/healthly

monitoring-check-logs:
	@printf "$(_CYAN)Vérification des logs...$(_END)\n"
	@docker-compose logs --tail=100 | grep -i "error"

monitoring-grafana-check:
	@printf "$(_CYAN)Vérification de Grafana...$(_END)\n"
	@curl -s http://grafana.localhost/api/health

monitoring-grafana-backup:
	@printf "$(_CYAN)Sauvegarde de Grafana...$(_END)\n"
	@mkdir -p backups/grafana/${DATE}
	@docker-compose exec grafana grafana-cli admin export-dashboard > backups/grafana/${DATE}/dashboard.json