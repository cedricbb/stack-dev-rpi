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