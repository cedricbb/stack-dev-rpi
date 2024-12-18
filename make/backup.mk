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

backup-rotate:
	@echo "${_CYAN}Rotation des sauvegardes...${_END}"
	@find backups/* -maxdepth 0 -type d -mtime +7 -exec rm -rf {} \;
	@echo "${_GREEN}Rotation terminée !${_END}"

backup-test:
	@echo "${_CYAN}Test de la fonctionnalité de backup...${_END}"
	@mkdir -p backups/test
	@make backup-list
	@echo "${_GREEN}Test terminé !${_END}"

daily-backup:
	@echo "${_CYAN}Sauvegarde quotidienne...${_END}"
	@make backup-now
	@make backup-clean
	@make backup-rotate
	@echo "${_GREEN}Sauvegarde quotidienne terminée !${_END}"

weekly-backup:
	@echo "${_CYAN}Sauvegarde hebdomadaire...${_END}"
	@make backup-now
	@tar -czf backups/weekly-$(DATE).tar.gz backups/latest/*
	@echo "${_GREEN}Sauvegarde hebdomadaire terminée !${_END}"