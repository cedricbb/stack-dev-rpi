#!make
include .env
export $(shell sed 's/=.*//' .env)

# Inclusion de tous les modules Makefile
-include make/*.mk

# Définition des variables globales
SHELL := /bin/bash
DOCKER_COMPOSE = docker-compose
DATE := $(shell date +%Y-%m-%d-%H-%M-%S)

# Liste des modules pour vérification
MODULES := install services database wordpress monitoring security backup

# Liste de toutes les commandes pour vérification de l'existence
COMMANDS := \
	install ssl generate-password apply-config \
	up down restart status logs \
	mysql-check mysql-repair mysql-optimize \
	postgres-check postgress-vacuum \
	bedrock-install bedrock-setup bedrock-composer bedrock-theme bedrock-plugin bedrock-update bedrock-dev \
	monitor-health metrics-check grafana-check grafana-backup \
	security-scan security-update ssl-check \
	clean-logs clean-resources optimize-containers \
	diagnose deep-analyze generate-report \
	service-isolate recreate \
	backup backup-verify restore restore-debug backup-clean \
	daily-check weekly-maintenance

# Vérification d'existence des commandes
$(COMMANDS):
	@if ! grep -q "^$@:" make/*.mk; then \
		echo "${_RED}Erreur: Commande '$@:' non trouvée dans les modules.${_END}"; \
		exit 1; \
	fi
	@$(MAKE) -f make/$(shell grep -l "^$@:" make/*.mk | head -1) $@

.PHONY: $(COMMANDS) help $(addsuffix -help, $(MODULES))

# Commande d'aide principale
help:
	@echo "\n${_BOLD}Stack de Développement - Commandes disponibles${_END}\n"
	@echo "${_GREEN}${_BOLD}Installation et configuration :${_END}"
	@make -s install-help
	@echo "\n${_GREEN}${_BOLD}Gestion des services :${_END}"
	@make -s services-help
	@echo "\n${_GREEN}${_BOLD}Monitoring :${_END}"
	@make -s monitoring-help
	@echo "\n${_GREEN}${_BOLD}Base de données :${_END}"
	@make -s database-help
	@echo "\n${_GREEN}${_BOLD}WordPress/Bedrock :${_END}"
	@make -s wordpress-help
	@echo "\n${_GREEN}${_BOLD}Sécurité :${_END}"
	@make -s security-help
	@echo "\n${_GREEN}${_BOLD}Backup et restauration :${_END}"
	@make -s backup-help
	@echo "\n${_GREEN}${_BOLD}Maintenance :${_END}"
	@echo "  make daily-check         		- Vérifications quotidiennes"
	@echo "  make weekly-maintenance        - Maintenance hebdomadaire"
	@echo "\n${_YELLOW}Pour plus de détails sur un module : make <module>-help${_END}\n"

# Vérification de modules
check-modules:
	@for module in $(MODULES); do \
		if [ ! -f make/$$module.mk ]; then \
			echo "${_RED}Erreur : Le module $$module n'existe pas.${_END}"; \
			exit 1; \
		fi; \
	done

# Initialisation
init: check-modules
	@echo "${_CYAN}Vérification de la structure des modules...${_END}"
	@for module in $(MODULES); do \
		if grep -q "^$$module-help" make/$$module.mk; then \
			echo "${_GREEN}Module $$module : OK !${_END}"; \
		else \
			echo "${_RED}Module $$module : Section d'aide manquante.${_END}"; \
			exit 1; \
		fi; \
	done

# Autocomplétion pour bash
generate-completion:
	@echo "complete -W '$(COMMANDS)' make" > make-completion.bash

# Vérification de l'environnement
check-env:
	@if [ ! -f .env ]; then \
		echo "${_RED}Fichier .env manquant${_END}"; \
		exit 1; \
	fi
	@echo "${_GREEN}Environnement : OK !${_END}"

# Liste de toutes les commandes disponibles
list-commands:
	@echo "${_CYAN}Commandes disponibles :${_END}"
	@echo "$(COMMANDS)" | tr ' ' '\n' | sort

# Alias utiles
start: up
stop: down
restart: down up
status: monitor-health

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

# CI/CD
gitlab-setup:
	@echo "${_CYAN}Configuration initiale de Gitlab...${_END}"
	@docker-compose up -d gitlab
	@echo "${_YELLOW}Attente du démarrage de Gitlab...${_END}"
	@sleep 30
	@echo "${_GREEN}Gitlab est prêt ! Access : https://gitlab.localhost${_END}"
	@echo "${_YELLOW}Mot de passe root : voir GITLAB_ROOT_PASSWORD dans .env${_END}"

# Documentation
docs-serve:
	@echo "${_CYAN}Démarrage du serveur de documentation...${_END}"
	@docker-compose up -d mkdocs
	@echo "${_GREEN}Documentation disponible sur http://docs.localhost ${_END}"