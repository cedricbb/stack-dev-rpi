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