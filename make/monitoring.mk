monitoring-setup:
	@echo "${_CYAN}Configuration du monitoring...${_END}"
	@docker-compose up -d prometheus grafana alertmanager portainer
	@mkdir -p config/grafana/dashboards
	@cp config/grafana/default/*.json config/grafana/dashboards/
	@docker-compose restart grafana
	@echo "${_GREEN}Monitoring configuré.${_END}"

monitoring-status:
	@echo "${_CYAN}État des services de monitoring :${_END}"
	@docker-compose ps portainer prometheus grafana

monitor-health:
	@echo "${_CYAN}Vérification de l'état des services...${_END}"
	@docker-compose ps -a
	@echo "\nContainer Resource Usage:"
	@docker stats --no-stream

monitor-resources:
	@echo "${_CYAN}Surveillance des ressources...${_END}"
	@docker stats --no-stream
	@echo "\nUtilisation disque:"
	@df -h
	@echo "\nUtilisation mémoire :"
	@free -h

alert-test:
	@echo "${_CYAN}Test d'alerte...${_END}"
	@curl -X POST -H "http://alertmanager:9093/api/v1/alerts" -d '[{"labels":{"alertname":"TestAlert","severity":"info"},"annotations":{"summary":"Alerte de test"}}]'

stats:
	@echo "${_CYAN}Statistiques système...${_END}"
	@docker-compose exec prometheus promtool query instant 'container_memory_usage_bytes'
	@docker-compose exec prometheus promtool query instant 'container_cpu_usage_seconds_total'

metrics-check:
	@echo "${_CYAN}Vérification des métriques...${_END}"
	@curl -s http://localhost:9090/-/healthly

check-logs:
	@echo "${_CYAN}Vérification des logs...${_END}"
	@docker-compose logs --tail=100 | grep -i "error"

grafana-check:
	@echo "${_CYAN}Vérification de Grafana...${_END}"
	@curl -s http://grafana.localhost/api/health

grafana-backup:
	@echo "${_CYAN}Sauvegarde de Grafana...${_END}"
	@mkdir -p backups/grafana/${DATE}
	@docker-compose exec grafana grafana-cli admin export-dashboard > backups/grafana/${DATE}/dashboard.json