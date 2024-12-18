# Test commands
test-all: test-docker test-services test-security test-monitoring

test-docker:
	@echo "${_CYAN}Test de la version de Docker...${_END}"
	@chmod +x scripts/test-services.sh
	@./scripts/test-services.sh docker

test-services:
	@echo "${_CYAN}Test des services de développement...${_END}"
	@./scripts/test-services.sh services

test-security:
	@echo "${_CYAN}Test de la sécurité des services...${_END}"
	@./scripts/test-services.sh security

test-monitoring:
	@echo "${_CYAN}Test des services de monitoring...${_END}"
	@./scripts/test-services.sh monitoring

test-ssl:
	@echo "${_CYAN}Test de la validité des certificats SSL...${_END}"
	@openssl x509 -in config/traefik/certs/domain.crt -text -noout

test-backup:
	@echo "${_CYAN}Test de la fonctionnalité de backup...${_END}"
	@make backup
	@make backup-list
	@echo "${_GREEN}Test terminé !${_END}"

validate-config:
	@echo "${_CYAN}Validation des fichiers de configuration...${_END}"
	@docker-compose config
	@echo "${_GREEN}Validation terminée !${_END}"

