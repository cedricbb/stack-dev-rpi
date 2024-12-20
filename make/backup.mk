.PHONY: backup-help backup-now backup-list backup-restore backup-verify \
restore-debug backup-clean backup-rotate backup-test daily-backup weekly-backup

backup-help:
	$(call print_title, Commandes de sauvegarde/restauration)
	$(call print_command, backup-now, Effectue une sauvegarde)
	$(call print_command, backup-list, Liste les sauvegardes disponibles)
	$(call print_command, backup-restore file=FILENAME, Restaure la sauvegarde file=FILENAME)
	$(call print_command, backup-verify file=FILENAME, Vérifie la sauvegarde file=FILENAME)
	$(call print_command, restore-debug file=FILENAME, Restauration en mode debug)
	$(call print_command, backup-clean, Nettoie les sauvegardes inutilisées)
	$(call print_command, backup-rotate, Rotation des sauvegardes)
	$(call print_command, backup-test, Teste la fonctionnalité de backup)
	$(call print_command, daily-backup, Sauvegarde quotidienne)
	$(call print_command, weekly-backup, Sauvegarde hebdomadaire)
# Backup
backup-now:
	@printf "$(_CYAN)Démarrage de la sauvegarde...$(_END)\n"
	@docker-compose run --rm backup backup
	@printf "$(_GREEN)Sauvegarde terminée !$(_END)\n"

backup-list:
	@printf "$(_CYAN)Liste des sauvegardes disponibles :$(_END)\n"
	@ls -lh backups/

backup-restore:
	@if [ -z "$(file)" ]; then \
		echo "$(_RED)Erreur: Spécifiez le fichier de sauvegarde avec file=FILENAME$(_END)\n"; \
		exit 1; \
	fi
	@printf "$(_CYAN)Restauration de la sauvegarde $(file)...$(_END)\n"
	@docker-compose down
	@docker-compose run --rm backup restore $(file)
	@docker-compose up -d
	@printf "$(_GREEN)Restauration terminée !$(_END)\n"

backup-verify:
	@printf "$(_CYAN)Vérification de la sauvegarde $(file)...$(_END)\n"
	@test -d "${BACKUP_DIR}/$(file)" || (echo "$(_RED)Erreur: Le fichier de sauvegarde $(file) n'existe pas$(_END)\n" && exit 1)
	@printf "$(_GREEN)Sauvegarde vérifiée$(_END)\n"

restore-debug:
	@printf "$(_CYAN)Restauration en mode debug...$(_END)\n"
	@make down
	@make restore file=$(file)
	@make up@make diagnose

backup-clean:
	@printf "$(_CYAN)Nettoyage des anciennes sauvegardes...$(_END)\n"
	@find ${BACKUP_DIR}/* -maxdepth 0 -type d -mtime +7 -exec rm -rf {} \;

backup-rotate:
	@printf "$(_CYAN)Rotation des sauvegardes...$(_END)\n"
	@find backups/* -maxdepth 0 -type d -mtime +7 -exec rm -rf {} \;
	@printf "$(_GREEN)Rotation terminée !$(_END)\n"

backup-test:
	@printf "$(_CYAN)Test de la fonctionnalité de backup...$(_END)\n"
	@mkdir -p backups/test
	@make backup-list
	@printf "$(_GREEN)Test terminé !$(_END)\n"

daily-backup:
	@printf "$(_CYAN)Sauvegarde quotidienne...$(_END)\n"
	@make backup-now
	@make backup-clean
	@make backup-rotate
	@printf "$(_GREEN)Sauvegarde quotidienne terminée !$(_END)\n"

weekly-backup:
	@printf "$(_CYAN)Sauvegarde hebdomadaire...$(_END)\n"
	@make backup-now
	@tar -czf backups/weekly-$(DATE).tar.gz backups/latest/*
	@printf "$(_GREEN)Sauvegarde hebdomadaire terminée !$(_END)\n"