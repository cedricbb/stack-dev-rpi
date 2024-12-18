# Sécurité
security-scan:
	@echo "${_CYAN}Analyse de sécurité des containers...${_END}"
	@docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image $(docker ps -q)
	@docker-compose exec security lynis audit system
	@echo "${_GREEN}Analyse terminée !${_END}"

security-update:
	@echo "${_CYAN}Mise à jour des certificats SSL...${_END}"
	@make ssl
	@docker-compose pull
	@make restart
	@echo "${_GREEN}Mise à jour terminée !${_END}"

ssl-check:
	@echo "${_CYAN}Vérification des certificats SSL...${_END}"
	@openssl x509 -in config/traefik/certs/domain.crt -text -noout

fail2ban-status:
	@echo "${_CYAN}Statut de Fail2Ban...${_END}"
	@docker-compose exec security fail2ban-client status
	@docker-compose exec security fail2ban-client status traefik-auth
	@echo "${_GREEN}Statut OK !${_END}"

pentest:
	@echo "${_CYAN}Tests de pénétration basiques...${_END}"
	@docker run --rm --network=backend securitytools/nmap -sV traefik
	@docker run --rm --network=backend securitytools/nikto -h traefik

firewall-status:
	@echo "${_CYAN}Statut du pare-feu...${_END}"
	@sudo ufw status verbose
	@docker-compose exec security iptables -L
	@echo "${_GREEN}Statut OK !${_END}"

cert-check:
	@echo "${_CYAN}Vérification des certificats...${_END}"
	@for cert in config/traefik/certs/*.crt; do \
		openssl x509 -in $$cert -text -noout | grep "Not After"; \ 
	done

security-clean:
	@echo "${_CYAN}Nettoyage des fichiers de sécurité...${_END}"
	@docker-compose exec security fail2ban-client unban --all
	@rm -f config/security/temp/*