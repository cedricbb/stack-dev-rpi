# Inclusion des configurations communes
include make/config.mk

# Variables spécifiques au module
DB_DUMPS_DIR := $(BACKUP_DIR)/databases
MYSQL_CONTAINER := mariadb
POSTGRES_CONTAINER := postgres

.PHONY: database-help database-check database-repair database-optimize \
database-backup database-restore database-vaccum database-status \
database-shell-mysql database-shell-postgres

database-help:
	$(call print_title, Commandes de gestion des Bases de Données)
	$(call print_command, database-check-mysql, Vérifie la connexion à la base de données)
	$(call print_command, database-repair-mysql, Répare la base de données)
	$(call print_command, database-optimize-mysql, Optimise la base de données)
	$(call print_command, database-check-postgres, Vérifie la connexion à la base de données)
	$(call print_command, database-vaccum-postgres, Nettoie la base de données)
	$(call print_command, database-shell-mysql, Ouvre le shell MySQL)
	$(call print_command, database-shell-postgres, Ouvre le shell PostgreSQL)
	$(call print_command, database-backup, Sauvegarde la base de donnée)

# Vérification des prérequis
database-check-prerequisites:
	@if [ ! -f .env ]; then \
		printf "$(_RED)Fichier .env manquant$(_END)\n"; \
		exit 1; \
	fi

# Fonctions MariaBD
database-check-mysql:
	@printf "$(_CYAN)Vérification de la base de données MariaDB...$(_END)\n"
	@docker-compose exec $(MYSQL_CONTAINER) mysqladmin -u root -p${DATABASE_PASSWORD} ping || exit 1
	@printf "$(_GREEN)La base de données MariaDB est opérationnelle.$(_END)\n"

database-repair-mysql:
	@printf "$(_CYAN)Réparation de la base de données MariaDB...$(_END)\n"
	@docker-compose exec $(MYSQL_CONTAINER) mysqlcheck -u root -p${DATABASE_PASSWORD} --auto-repair --all-databases
	@printf "$(_GREEN)Réparation terminée.$(_END)\n"

database-optimize-mysql:
	@printf "$(_CYAN)Optimisation de la base de données MariaDB...$(_END)\n"
	@docker-compose exec $(MYSQL_CONTAINER) mysqlcheck -u root -p${DATABASE_PASSWORD} --optimize --all-databases
	@printf "$(_GREEN)Optimisation terminée.$(_END)\n"

# Fonctions PostgreSQL
database-check-postgres:
	@printf "$(_CYAN)Vérification de la base de données PostgreSQL...$(_END)\n"
	@docker-compose exec $(POSTGRES_CONTAINER) pg_isready -U postgres || exit 1
	@printf "$(_GREEN)La base de données PostgreSQL est opérationnelle.$(_END)\n"

database-vaccum-postgres:
	@printf "$(_CYAN)Nettoyage de la base de données PostgreSQL...$(_END)\n"
	@docker-compose exec $(POSTGRES_CONTAINER) vacuumdb -U postgres --all --analyze
	@printf "$(_GREEN)Nettoyage terminé.$(_END)\n"
	
# Commandes combinées
database-check: database-check-mysql database-check-postgres
	@printf "$(_GREEN)Toutes les bases de données sont opérationnelles$(_END)\n"

database-optimize: database-optimize-mysql database-vaccum-postgres
	@printf "$(_GREEN)Optimisation terminée.$(_END)\n"

database-status:
	@printf "$(_CYAN)Statut des bases de données...$(_END)\n"
	@printf "\nMariaDB :"
	@docker-compose exec $(MYSQL_CONTAINER) mysqladmin -u root -p${DATABASE_PASSWORD} status
	@printf "\nPostgreSQL :"
	@docker-compose exec $(POSTGRES_CONTAINER) psql -U postgres -c "SELECT version();"

#shells de base de données
database-shell-mysql:
	@printf "$(_CYAN)Ouverture du shell MySQL...$(_END)\n"
	@$(DOCKER_COMPOSE) exec $(MYSQL_CONTAINER) mysql -u root -${DATABASE_PASSWORD}

database-shell-postgres:
	@printf "$(_CYAN)Ouverture du shell PostgreSQL...$(_END)\n"
	@$(DOCKER_COMPOSE) exec p$(POSTGRES_CONTAINER) psql -U postgres -d ${POSTGRES_DATABASE_NAME}

# Sauvegarde et restauration
database-backup:
	@printf "$(_CYAN)Sauvegarde des bases de données...$(_END)\n"
	@mkdir -p $(DB_DUMPS_DIR)/$(DATE)
	@docker-compose exec $(MYSQL_CONTAINER) mysqldump -u root -p${DATABASE_PASSWORD} --all-databases > dumps/$(DATE)/mysql_backup.sql
	@docker-compose exec $(POSTGRES_CONTAINER) pg_dumpall -U postgres > dumps/$(DATE)/postgres_backup.sql
	@printf "$(_GREEN)Sauvegarde terminée dans $(DB_DUMPS_DIR)/$(DATE) !$(_END)\n"

database-restore:
	@if [ -z "$(backup)" ]; then \
		@printf "$(_RED)Erreur: Spécifiez une sauvegarde avec backup=DATE$(_END)\n"; \
		exit 1; \
	fi
	@printf "$(_CYAN)Restauration des bases de données...$(_END)\n"
	@docker-compose exec -T $(MYSQL_CONTAINER) mysql -u root -p${DATABASE_PASSWORD} < $(DB_DUMPS_DIR)/$(backup)/mysql_backup.sql
	@docker-compose exec -T $(POSTGRES_CONTAINER) psql -U postgres < $(DB_DUMPS_DIR)/$(backup)/postgres_backup.sql
	@printf "$(_GREEN)Restauration terminée !$(_END)\n"

# Hooks pour les autres modules
database-init: database-check
database-cleanup: database-optimize