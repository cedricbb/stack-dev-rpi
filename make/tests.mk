.PHONY: test-all test-docker test-services test-security test-monitoring test-ssl test-backup test-validate-config

tests-help:
	$(call print_title, Commandes de test)
	$(call print_command, test-all, Test complet)
	$(call print_command, test-docker, Test de la version de Docker)
	$(call print_command, test-services, Test des services de développement)
	$(call print_command, test-security, Test de la sécurité des services)
	$(call print_command, test-monitoring, Test des services de monitoring)
	$(call print_command, test-ssl, Test de la validité des certificats SSL)
	$(call print_command, test-backup, Test de la fonctionnalité de backup)
	$(call print_command, test-validate-config, Validation des fichiers de configuration)

# Test commands
test-all: test-docker test-services test-security test-monitoring

test-docker:
	@printf "$(_CYAN)Test de la version de Docker...$(_END)\n"
	@chmod +x scripts/test-services.sh
	@./scripts/test-services.sh docker

test-services:
	@printf "$(_CYAN)Test des services de développement...$(_END)\n"
	@./scripts/test-services.sh services

test-security:
	@printf "$(_CYAN)Test de la sécurité des services...$(_END)\n"
	@./scripts/test-services.sh security

test-monitoring:
	@printf "$(_CYAN)Test des services de monitoring...$(_END)\n"
	@./scripts/test-services.sh monitoring

test-ssl:
	@printf "$(_CYAN)Test de la validité des certificats SSL...$(_END)\n"
	@openssl x509 -in config/traefik/certs/domain.crt -text -noout

test-backup:
	@printf "$(_CYAN)Test de la fonctionnalité de backup...$(_END)\n"
	@make backup
	@make backup-list
	@printf "$(_GREEN)Test terminé !$(_END)\n"

test-validate-config:
	@printf "$(_CYAN)Validation des fichiers de configuration...$(_END)\n"
	@docker-compose config
	@printf "$(_GREEN)Validation terminée !$(_END)\n"

