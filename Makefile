MAKEFLAGS += --no-print-directory
export TERM=xterm-256color

# Inclusion des variables d'environnement
include .env

# Définition des modules
MODULES := install services database wordpress monitoring security backup maintenance tests dev 
export $(shell sed 's/=.*//' .env)

# Définition des variables globales
SHELL := /bin/bash
DATE := $(shell date +%Y-%m-%d-%H-%M-%S)

# Inclusion des couleurs
include scripts/colors.sh

define print_title
	@printf "$(_GREEN)$(_BOLD)$(1) :$(_END)\n";
endef

define print_command
	@printf "$(_CYAN)make %-30s - %s\n" "$(1)" "$(2)"
endef

# Inclusion de tous les modules Makefile
-include $(foreach module, $(MODULES), make/$(module).mk)

.PHONY: help $(MODULES) $(foreach module, $(MODULES), $(module)-help)

# Commande d'aide principale
help:
	@printf "\n$(_BOLD)Stack de Développement - Commandes disponibles$(_END)\n\n"
	@for module in $(MODULES); do \
		printf "$(_YELLOW)$(_BOLD)Module $$module$(_END)\n"; \
		$(MAKE) $$module-help 2>/dev/null || true; \
		printf "\n"; \
	done

debug-modules:
	@printf "Modules définis : $(MODULES)"
	@printf "\nRecherche des fichiers dans make/ :"
	@ls -la make/*.mk

# Vérification de l'environnement
check-env:
	@if [ ! -f .env ]; then \
		printf "$(_RED)Fichier .env manquant$(_END)\n"; \
		exit 1; \
	fi
	@printf "$(_GREEN)Environnement : OK !$(_END)\n"

# Alias utiles
start: up
stop: down
restart: down up
status: monitor-health

# VPN
vpn-install:
	@printf "${_CYAN}Installation de Wireguard...$(_END)\n"
	@chmod +x install-wireguard.sh
	@sudo ./install-wireguard.sh
	@printf "$(_GREEN)Wireguard installé !$(_END)\n"

vpn-client:
	@printf "${_CYAN}Génération de la configuration client...$(_END)\n"
	@printf "Client public key: $(shell sudo cat /etc/wireguard/pulic.key)"
	@printf "Server IP: $(shell curl -s ifconfig.me)"
	@printf "$(_YELLOW)Utilisez ces informations pour configurer le client WireGuard$(_END)\n"

vpn-status:
	@printf "${_CYAN}État de WireGuard$(_END)\n"
	@sudo wg show

# CI/CD
gitlab-setup:
	@printf "${_CYAN}Configuration initiale de Gitlab...$(_END)\n"
	@docker-compose up -d gitlab
	@printf "$(_YELLOW)Attente du démarrage de Gitlab...$(_END)\n"
	@sleep 30
	@printf "$(_GREEN)Gitlab est prêt ! Access : https://gitlab.localhost$(_END)\n"
	@printf "$(_YELLOW)Mot de passe root : voir GITLAB_ROOT_PASSWORD dans .env$(_END)\n"

# Documentation
docs-serve:
	@printf "${_CYAN}Démarrage du serveur de documentation...$(_END)\n"
	@docker-compose up -d mkdocs
	@printf "$(_GREEN)Documentation disponible sur http://docs.localhost $(_END)\n"