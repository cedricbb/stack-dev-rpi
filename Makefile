#!make
include .env
export $(shell sed 's/=.*//' .env)

# Couleurs pour le terminal
_END=$'\033[0m
_BOLD=$'\033[1m
_RED=$'\033[31m
_GREEN=$'\033[32m
_YELLOW=$'\033[33m
_BLUE=$'\033[34m
_PURPLE=$'\033[35m
_CYAN=$'\033[36m
_WHITE=$'\033[37m

# Variables générales
DOCKER_COMPOSE = docker-compose
CURRENT_DIR = $(shell pwd)
DATE := $(shell date +%Y-%m-%d-%H-%M-%S)

.PHONY: help install up down restart status logs clean ssl php-shell node-shell mysql-shell postgres-shell backup restore

help:
	@echo "\n${_BOLD}Stack de Développement - Commandes disponibles${_END}\n"
	@echo "${_GREEN}${_BOLD}Installation et configuration :${_END}"
	@echo "  make install         - Installation initiale"
	@echo "  make ssl            - Générer les certificats SSL"
	@echo "  make update         - Mettre à jour la stack"
	@echo "\n${_GREEN}${_BOLD}Gestion des services :${_END}"
	@echo "  make up             - Démarrer les services"
	@echo "  make down           - Arrêter les services"
	@echo "  make restart        - Redémarrer les services"
	@echo "  make status         - État des services"
	@echo "  make logs           - Voir les logs"
	@echo "\n${_GREEN}${_BOLD}Monitoring :${_END}"
	@echo "  make monitor-health - Vérifier la santé"
	@echo "  make metrics-check  - Vérifier les métriques"
	@echo "\n${_GREEN}${_BOLD}Base de données :${_END}"
	@echo "  make mysql-check    - Vérifier MariaDB"
	@echo "  make postgres-check - Vérifier PostgreSQL"
	@echo "\n${_GREEN}${_BOLD}Sécurité :${_END}"
	@echo "  make security-scan  - Scanner la sécurité"
	@echo "  make security-update- Mettre à jour la sécurité"
	@echo "\n${_GREEN}${_BOLD}Backup :${_END}"
	@echo "  make backup         - Créer une sauvegarde"
	@echo "  make restore        - Restaurer une sauvegarde"

install:
	@echo "${_CYAN}Création des dossiers...${_END}"
	mkdir -p config/{prometheus,grafana,traefik/certs,nginx,php,mariadb,postgres,redis}
	mkdir -p projects/{php,node,react,next,nuxt,angular,flutter}
	mkdir -p backups logs/{traefik, nginx, fail2ban} data/{grafana, prometheus, gitlab, portainer}
	@echo "${_CYAN}Création du réseau docker...${_END}"
	docker network create backend || true
	@echo "${_GREEN}Installation terminée !${_END}"

ssl:
	@echo "${_CYAN}Génération des certificats SSL...${_END}"
	@chmod +x ssl.sh
	@./ssl.sh
	@echo "${_GREEN}Certificats et SSL générés !${_END}"

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

php-shell:
	@echo "${_CYAN}Ouverture du shell PHP...${_END}"
	@$(DOCKER_COMPOSE) exec apache-php bash

node-shell:
	@echo "${_CYAN}Ouverture du shell Node.js...${_END}"
	@$(DOCKER_COMPOSE) exec nodejs bash

mysql-shell:
	@echo "${_CYAN}Ouverture du shell MySQL...${_END}"
	@$(DOCKER_COMPOSE) exec mariadb mysql -u root -${DATABASE_PASSWORD}

postgres-shell:
	@echo "${_CYAN}Ouverture du shell PostgreSQL...${_END}"
	@$(DOCKER_COMPOSE) exec postgres psql -U postgres -d ${POSTGRES_DATABASE_NAME}

backup:
	@echo "${_CYAN}Sauvegarde des bases de données...${_END}"
	@mkdir -p dumps/$(DATE)
	@docker exec mariadb mysqldump -u root -p${DATABASE_PASSWORD} --all-databases > dumps/$(DATE)/mysql_backup.sql
	@docker exec postgres pg_dumpall -U postgres > dumps/$(DATE)/postgres_backup.sql
	@echo "${_GREEN}Sauvegarde terminée dans dumps/$(DATE) !${_END}"

restore:
	@if [ -z "$(dump)" ]; then \
		@echo "${_RED}Erreur: Spécifiez le dossier de auvegarde avec dump=DOSSIER${_END}"; \
		exit 1; \
	fi
	@echo "${_CYAN}Restauration des bases de données...${_END}"
	@docker exec -i mariadb mysql -u root -p${DATABASE_PASSWORD} < dumps/$(dump)/mysql_backup.sql
	@docker exec -i postgres psql -U postgres < dumps/$(dump)/postgres_backup.sql
	@echo "${_GREEN}Restauration terminée !${_END}"

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

# VPN
vpn-install:
	@echo "${_CYAN}Installation de Wireguard...${_END}"
	@chmod +x install-wireguard.sh
	@sudo ./install-wireguard.sh
	@echo "${_GREEN}Wireguard installé !${_END}"

vpn-client:
	@echo "${_CYAN}Génération de la configuration client...${_END}"
	@echo "Client public key: $(shell sudo cat /etc/wireguard/pulic.key)"
	@echo "Server IP: $(shell curl -s ifconfig.me)"
	@echo "${_YELLOW}Utilisez ces informations pour configurer le client WireGuard${_END}"

vpn-status:
	@echo "${_CYAN}État de WireGuard${_END}"
	@sudo wg show

# Monitoring
monitoring-up:
	@echo "${_CYAN}Démarrage des services de monitoring...${_END}"
	@docker-compose up -d portainer prometheus grafana
	@echo "${_GREEN}Services de monitoring démarrés !${_END}"

monitoring-status:
	@echo "${_CYAN}État des services de monitoring :${_END}"
	@docker-compose ps portainer prometheus grafana

monitor-health:
	@echo "${_CYAN}Vérification de l'état des services...${_END}"
	@docker-compose ps
	@docker stats --no-stream

metrics-check:
	@echo "${_CYAN}Vérification des métriques...${_END}"
	@curl -s http://localhost:9090/-/healthly

grafana-check:
	@echo "${_CYAN}Vérification de Grafana...${_END}"
	@curl -s http://grafana.localhost/api/health

grafana-backup:
	@echo "${_CYAN}Sauvegarde de Grafana...${_END}"
	@mkdir -p backups/grafana/${DATE}
	@docker-compose exec grafana grafana-cli admin export-dashboard > backups/grafana/${DATE}/dashboard.json

# CI/CD
gitlab-setup:
	@echo "${_CYAN}Configuration initiale de Gitlab...${_END}"
	@docker-compose up -d gitlab
	@echo "${_YELLOW}Attente du démarrage de Gitlab...${_END}"
	@sleep 30
	@echo "${_GREEN}Gitlab est prêt ! Access : https://gitlab.localhost${_END}"
	@echo "${_YELLOW}Mot de passe root : voir GITLAB_ROOT_PASSWORD dans .env${_END}"

# Backup
backup-now:
	@echo "${_CYAN}Démarrage de la sauvegarde...${_END}"
	@docker-compose run --rm backup backup
	@echo "${_GREEN}Sauvegarde terminée !${_END}"

backup-list:
	@echo "${_CYAN}Liste des sauvegardes disponibles :${_END}"
	@ls -lh backups/

backup-restore:
	@if [ -z "$(file)" ]; then \
		echo "${_RED}Erreur: Spécifiez le fichier de sauvegarde avec file=FILENAME${_END}"; \
		exit 1; \
	fi
	@echo "${_CYAN}Restauration de la sauvegarde $(file)...${_END}"
	@docker-compose down
	@docker-compose run --rm backup restore $(file)
	@docker-compose up -d
	@echo "${_GREEN}Restauration terminée !${_END}"

backup-verify:
	@echo "${_CYAN}Vérification de la sauvegarde $(file)...${_END}"
	@test -d "${BACKUP_DIR}/$(file)" || (echo "${_RED}Erreur: Le fichier de sauvegarde $(file) n'existe pas${_END}" && exit 1)
	@echo "${_GREEN}Sauvegarde vérifiée${_END}"

restore-debug:
	@echo "${_CYAN}Restauration en mode debug...${_END}"
	@make down
	@make restore file=$(file)
	@make up@make diagnose

backup-clean:
	@echo "${_CYAN}Nettoyage des anciennes sauvegardes...${_END}"
	@find ${BACKUP_DIR}/* -maxdepth 0 -type d -mtime +7 -exec rm -rf {} \;

# Sécurité
security-scan:
	@echo "${_CYAN}Analyse de sécurité des containers...${_END}"
	@docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image $(docker ps -q)
	@echo "${_GREEN}Analyse terminée !${_END}"

security-update:
	@echo "${_CYAN}Mise à jour des certificats SSL...${_END}"
	@make ssl
	@docker-compose pull
	@make restart
	@echo "${_GREEN}Mise à jour terminée !${_END}"

ssl-check:
	@echo "${_CYAN}Vérification des certificats SSL...${_END}"
	@openssl x509 -in config/traefik/certs/domain.crt -text -noout

# Documentation
docs-serve:
	@echo "${_CYAN}Démarrage du serveur de documentation...${_END}"
	@docker-compose up -d mkdocs
	@echo "${_GREEN}Documentation disponible sur http://docs.localhost ${_END}"

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

# Test commands
test-all: test-docker test-services test-security test-monitoring

test-docker:
	@echo "${_CYAN}Test de la version de Docker...${_END}"
	@chmod +x scripts/test-services.sh
	@./scripts/test-services.sh docker

test-services:
	@echo "${_CYAN}Test des services de développement...${_END}"
	@./scripts/test-services.sh services

test-security:
	@echo "${_CYAN}Test de la sécurité des services...${_END}"
	@./scripts/test-services.sh security

test-monitoring:
	@echo "${_CYAN}Test des services de monitoring...${_END}"
	@./scripts/test-services.sh monitoring

test-ssl:
	@echo "${_CYAN}Test de la validité des certificats SSL...${_END}"
	@openssl x509 -in config/traefik/certs/domain.crt -text -noout

test-backup:
	@echo "${_CYAN}Test de la fonctionnalité de backup...${_END}"
	@make backup
	@make backup-list
	@echo "${_GREEN}Test terminé !${_END}"

validate-config:
	@echo "${_CYAN}Validation des fichiers de configuration...${_END}"
	@docker-compose config
	@echo "${_GREEN}Validation terminée !${_END}"

check-logs:
	@echo "${_CYAN}Vérification des logs...${_END}"
	@docker-compose logs --tail=100 | grep -i "error"

monitor-health:
	@echo "${_CYAN}Vérification de l'état des services...${_END}"
	@docker-compose ps -a
	@echo "\nContainer Resource Usage:"
	@docker stats --no-stream

# Générer des mots de passe sécurisés
generate-password:
	@echo "${_CYAN}Génération des mots de passe sécurisés...${_NC}"
	@if [ ! -f  .env ]; then \
		cp .env.example .env; \
	fi
	@echo "${_YELLOW}Génération des nouveaux mots de passe...${_NC}"
	# Génération des mots de passe
	@DATABASE_PASSWORD=$$(openssl rand -base64 32) && \
	POSTGRES_PASSWORD=$$(openssl rand -base64 32) && \
	GRAFANA_PASSWORD=$$(openssl rand -base64 32) && \
	GITLAB_ROOT_PASSWORD=$$(openssl rand -base64 32) && \
	REDIS_PASSWORD=$$(openssl rand -base64 32) && \
	VSCODDE_PASSWORD=$$(openssl rand -base64 32) && \
	sed -i "s/DATABASE_PASSWORD=.*/DATABASE_PASSWORD=$$DATABASE_PASSWORD/" .env && \
	sed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_DATABASE_PASSWORD=$$POSTGRES_PASSWORD/" .env && \
	sed -i "s/GRAFANA_PASSWORD=.*/GRAFANA_PASSWORD=$$GRAFANA_PASSWORD/" .env && \
	sed -i "s/GITLAB_ROOT_PASSWORD=.*/GITLAB_ROOT_PASSWORD=$$GITLAB_ROOT_PASSWORD/" .env && \
	sed -i "s/REDIS_PASSWORD=.*/REDIS_PASSWORD=$$REDIS_PASSWORD/" .env && \
	sed -i "s/VSCODDE_PASSWORD=.*/VSCODDE_PASSWORD=$$VSCODDE_PASSWORD/" .env &&
	echo "${_GREEN}Mots de passe générés et enregistrés dans le fichier .env${_NC}"
	@echo "${_YELLOW}Important: Conservez soigneusement les mots de passe générés. Ils ne pourront être récupérés ultérieurement.${_NC}"

# Appliquer les configurations
apply-config:
	@echo "${_BLUE}Application des configurations...${_NC}"

	# Création des dossiers nécessaires
	@echo "${_YELLOW}Création des dossiers de configuration...${_NC}"
	@mkdir -p config/{prometheus,grafana,traefik/certs,nginx,php,mariadb,postgres,redis}

	# Copie et configuration des fichiers
	@echo "${_YELLOW}Copie des fichiers de configuration...${_NC}"
	# Prometheus
	@cp -n config/prometheus/prometheus.yml config/prometheus/prometheus.yml.backup 2>/dev/null || true
	@envsubst < config/prometheus/prometheus.yml > config/prometheus/prometheus.yml.tmp
	@mv config/prometheus/prometheus.yml.tmp config/prometheus/prometheus.yml
	# Grafana
	@cp -n config/grafana/grafana.ini config/grafana/grafana.ini.backup 2>/dev/null || true
	@envsubst < config/grafana/grafana.ini > config/grafana/grafana.ini.tmp
	@mv config/grafana/grafana.ini.tmp config/grafana/grafana.ini
	# PHP
	@cp -n config/php/php.ini config/php/php.ini.backup 2>/dev/null || true
	@envsubst < config/php/php.ini > config/php/php.ini.tmp
	@mv config/php/php.ini.tmp config/php/php.ini
	# MariaDB
	@cp -n config/mariadb/my.cnf config/mariadb/my.cnf.backup 2>/dev/null || true
	@envsubst < config/mariadb/my.cnf > config/mariadb/my.cnf.tmp
	@mv config/mariadb/my.cnf.tmp config/mariadb/my.cnf
	# PostgreSQL
	@cp -n config/postgres/postgresql.conf config/postgres/postgresql.conf.backup 2>/dev/null || true
	@envsubst < config/postgres/postgresql.conf > config/postgres/postgresql.conf.tmp
	@mv config/postgres/postgresql.conf.tmp config/postgres/postgresql.conf

	# Configuration des permissions
	@echo "${_YELLOW}Configuration des permissions...${_NC}"
	@chmod 600 config/traefik/certs/*
	@chmod 644 config/**/*.{yml,yaml,conf,ini,toml}

	# Redémarrage des services si nécessaires
	@echo "${_YELLOW}Voulez-vous redémarrer les services pour appliquer les configurations ? [y/N]${_NC}"
	@read -p  "" answer; \
	@if [ "$${answer}" = "y" ] || [ "$${answer}" = "Y" ]; then \
		echo "${_BLUE}Redémarrage des services...${_NC}"
		docker-compose down && docker-compose up -d; \
		echo "${_GREEN}Services redémarrés avec les nouvelles configurations !${_NC}"
	else \
		echo "${_YELLOW}Les services n'ont pas été redémarrés. Les changements seront appliqués au prochain redémarrage.${_NC}"
	fi

	@echo "${_GREEN}Configuration appliquée avec succès !${_NC}"
	@echo "${_YELLOW}Important: N'oubliez pas de vérifier les fichiers de configuration et de redémarrer les services si nécessaire.${_NC}"

# Base de données
mysql-check:
	@echo "${_CYAN}Vérification de la base de données MariaDB...${_END}"
	@docker-compose exec mariadb mysqladmin -u root -p${DATABASE_PASSWORD} ping || exit 1
	@echo "${_GREEN}La base de données MariaDB est opérationnelle.${_END}"

mysql-repair:
	@echo "${_CYAN}Réparation de la base de données MariaDB...${_END}"
	@docker-compose exec mariadb mysqlcheck -u root -p${DATABASE_PASSWORD} --auto-repair --all-databases
	@echo "${_GREEN}Réparation terminée.${_END}"

mysql-optimize:
	@echo "${_CYAN}Optimisation de la base de données MariaDB...${_END}"
	@docker-compose exec mariadb mysqlcheck -u root -p${DATABASE_PASSWORD} --optimize --all-databases
	@echo "${_GREEN}Optimisation terminée.${_END}"

postgres-check:
	@echo "${_CYAN}Vérification de la base de données PostgreSQL...${_END}"
	@docker-compose exec postgres pg_isready -U postgres || exit 1
	@echo "${_GREEN}La base de données PostgreSQL est opérationnelle.${_END}"

postgres-vacuum:
	@echo "${_CYAN}Nettoyage de la base de données PostgreSQL...${_END}"
	@docker-compose exec postgres vacuumdb -U postgres --all --analyze
	@echo "${_GREEN}Nettoyage terminé.${_END}"
	
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

# Maintenance périodique
daily-check: monitor-health mysql-check postgres-check

weekly-maintenance: clean-logs optimize-containers backup