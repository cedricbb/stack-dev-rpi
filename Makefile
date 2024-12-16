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
	@echo " ${_BOLD}make install${_END}			- Prépare l'environnement (crée les dossiers et le réseau)"
	@echo " ${_BOLD}make ssl${_END}				- Génère les certificats SSL"
	@echo "\n${_GREEN}${_BOLD}Gestion des containers :${_END}"
	@echo " ${_BOLD}make up${_END}				- Démarre tous les services"
	@echo " ${_BOLD}make down${_END}			- Arrête tous les services"
	@echo " ${_BOLD}make restart${_END}			- Redémarre tous les services"
	@echo " ${_BOLD}make status${_END}			- Affiche l'état des services"
	@echo "\n${_GREEN}${_BOLD}Logs :${_END}"
	@echo " ${_BOLD}make logs${_END}			- Affiche les logs de tous les services"
	@echo " ${_BOLD}make logs s=SERVICE${_END}	- Affiche les logs d'un service spécifique"
	@echo "\n${_GREEN}${_BOLD}Accès aux shells :${_END}"
	@echo " ${_BOLD}make php-shell${_END}		- Ouvre un shell dans le container PHP"
	@echo " ${_BOLD}make node-shell${_END}		- Ouvre un shell dans le container Node.js"
	@echo " ${_BOLD}make mysql-shell${_END}		- Ouvre un shell MySQL"
	@echo " ${_BOLD}make postgres-shell${_END}	- Ouvre un shell PostgresSQL"
	@echo "\n${_GREEN}${_BOLD}Sauvegarde et restauration :${_END}"
	@echo " ${_BOLD}make backup${_END}			- Sauvegarde toutes les bases de données"
	@echo " ${_BOLD}make restore${_END}			- Restaure la derniére sauvegarde"
	@echo "\n${_GREEN}${_BOLD}Nettoyage :${_END}"
	@echo " ${_BOLD}make clean${_END}			- Supprime tous les containers et volumes"
	@echo "\n${_GREEN}${_BOLD}VPN :${_END}"
	@echo " ${_BOLD}make vpn-install${_END}		- Installe WireGuard"
	@echo " ${_BOLD}make vpn-client${_END}		- Génère la configuration client"
	@echo " ${_BOLD}make vpn-status${_END}		- Affiche l'état de Wireguard"
	@echo "\n"

install:
	@echo "${_CYAN}Création des dossiers...${_END}"
	@mkdir -p projects/php projects/node dumps traefik
	@echo "${_CYAN}Création du réseau docker...${_END}"
	@docker network create backend || true
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

node-shell
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