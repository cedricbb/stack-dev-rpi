.PHONY: install-help install install-check install-deps- install-dirs install-ssl install-network

install-help:
	$(call print_title, Commandes d'installation)
	$(call print_command, install, Installe l'environnement de développement)
	$(call print_command, install-check, Vérifie si toutes les dépendances sont installées)
	$(call print_command, install-ssl, Génère les certificats SSL)
	$(call print_command, install-deps, Crée le réseau Docker)
	$(call print_command, install-dirs, Crée les dossiers nécessaires)
	$(call print_command, install-network, Crée le réseau Docker)

install:
	@printf "$(_CYAN)Création des dossiers...$(_END)\n"
	mkdir -p config/{prometheus,grafana,traefik/certs,nginx,php,mariadb,postgres,redis}
	mkdir -p projects/{php,node,react,next,nuxt,angular,flutter}
	mkdir -p backups logs/{traefik, nginx, fail2ban} data/{grafana, prometheus, gitlab, portainer}
	@printf "$(_CYAN)Création du réseau docker...$(_END)\n"
	docker network create backend || true
	@printf "$(_GREEN)Installation terminée !$(_END)\n"

install-check:
	@printf "$(_CYAN)Vérification des prérequis...$(_END)\n"
	@printf "$(_YELLOW)Vérification de Docker...$(_END)\n"
	@docker --version
	@printf "$(_YELLOW)Vérification de Docker Compose...$(_END)\n"
	@docker-compose --version
	@printf "$(_YELLOW)Vérification de Git...$(_END)\n"
	@git --version
	@printf "$(_YELLOW)Vérification de OpenSSL...$(_END)\n"
	@openssl version
	@printf "$(_GREEN)Prérequis vérifiés !$(_END)\n"

install-deps:
	@printf "$(_CYAN)Installation des dépendances...$(_END)\n"
	@printf "$(_YELLOW)Installation de Docker...$(_END)\n"
	@curl -fsSL https://get.docker.com -o get-docker.sh
	@sh get-docker.sh
	@printf "$(_YELLOW)Installation de Docker Compose...$(_END)\n"
	@sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	@sudo chmod +x /usr/local/bin/docker-compose
	@printf "$(_YELLOW)Installation de Git...$(_END)\n"
	@sudo apt-get update
	@sudo apt-get install -y git
	@printf "$(_YELLOW)Installation de OpenSSL
	@sudo apt-get install -y openssl
	@printf "$(_YELLOW)Installation de Make...$(_END)\n"
	@sudo apt-get install -y make
	@printf "$(_GREEN)Dépendances installées !$(_END)\n"

install-dirs:
	@printf "$(_CYAN)Création des dossiers...$(_END)\n"
	mkdir -p config/{prometheus,grafana,traefik/certs,nginx,php,mariadb,postgres,redis}
	mkdir -p projects/{php,node,react,next,nuxt,angular,flutter}
	mkdir -p backups logs/{traefik, nginx, fail2ban} data/{grafana, prometheus, gitlab, portainer}
	@printf "$(_GREEN)Dossiers créés !$(_END)\n"

install-ssl:
	@printf "$(_CYAN)Génération des certificats SSL...$(_END)\n"
	@chmod +x ssl.sh
	@./ssl.sh
	@printf "$(_GREEN)Certificats et SSL générés !$(_END)\n"

install-network:
	@printf "$(_CYAN)Création du réseau Docker...$(_END)\n"
	docker network create backend || true
	@printf "$(_GREEN)Réseau Docker créé !$(_END)\n"

# Générer des mots de passe sécurisés
generate-password:
	@printf "$(_CYAN)Génération des mots de passe sécurisés...$(_END)\n"
	@if [ ! -f  .env ]; then \
		cp .env.example .env; \
	fi
	@printf "$(_YELLOW)Génération des nouveaux mots de passe...$(_END)\n"
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
	printf "$(_GREEN)Mots de passe générés et enregistrés dans le fichier .env$(_END)\n"
	@printf "$(_YELLOW)Important: Conservez soigneusement les mots de passe générés. Ils ne pourront être récupérés ultérieurement.$(_END)\n"

# Appliquer les configurations
apply-config:
	@printf "$(_BLUE)Application des configurations...$(_END)\n"

	# Création des dossiers nécessaires
	@printf "$(_YELLOW)Création des dossiers de configuration...$(_END)\n"
	@mkdir -p config/{prometheus,grafana,traefik/certs,nginx,php,mariadb,postgres,redis}

	# Copie et configuration des fichiers
	@printf "$(_YELLOW)Copie des fichiers de configuration...$(_END)\n"
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
	@printf "$(_YELLOW)Configuration des permissions...$(_END)\n"
	@chmod 600 config/traefik/certs/*
	@chmod 644 config/**/*.{yml,yaml,conf,ini,toml}

	# Redémarrage des services si nécessaires
	@printf "$(_YELLOW)Voulez-vous redémarrer les services pour appliquer les configurations ? [y/N]$(_END)\n"
	@read -p  "" answer; \
	@if [ "$${answer}" = "y" ] || [ "$${answer}" = "Y" ]; then \
		printf "$(_BLUE)Redémarrage des services...$(_END)\n"
		docker-compose down && docker-compose up -d; \
		printf "$(_GREEN)Services redémarrés avec les nouvelles configurations !$(_END)\n"
	else \
		printf "$(_YELLOW)Les services n'ont pas été redémarrés. Les changements seront appliqués au prochain redémarrage.$(_END)\n"
	fi

	@printf "$(_GREEN)Configuration appliquée avec succès !$(_END)\n"
	@printf "$(_YELLOW)Important: N'oubliez pas de vérifier les fichiers de configuration et de redémarrer les services si nécessaire.$(_END)\n"