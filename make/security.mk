.PHONY: security-scan security-update security-ssl-check security-fail2ban-status \
security-pentest security-firewall-status security-cert-check security-clean

security-help:
	$(call print_title, Commandes de sécurité)
	$(call print_command, security-scan, Analyse de sécurité des containers)
	$(call print_command, security-update, Mise à jour des certificats SSL)
	$(call print_command, security-ssl-check, Vérification des certificats SSL)
	$(call print_command, security-fail2ban-status, Statut de Fail2Ban)
	$(call print_command, security-pentest, Test de sécurité)
	$(call print_command, security-firewall-status, Statut du pare-feu)
	$(call print_command, security-cert-check, Vérification des certificats)
	$(call print_command, security-clean, Nettoyage des fichiers temporaires)

# Sécurité
security-scan:
	@printf "${_CYAN}Analyse de sécurité des containers...${_END}"
	@docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image $(docker ps -q)
	@docker-compose exec security lynis audit system
	@printf "${_GREEN}Analyse terminée !${_END}"

security-update:
	@printf "${_CYAN}Mise à jour des certificats SSL...${_END}"
	@make ssl
	@docker-compose pull
	@make restart
	@printf "${_GREEN}Mise à jour terminée !${_END}"

security-ssl-check:
	@printf "${_CYAN}Vérification des certificats SSL...${_END}"
	@openssl x509 -in config/traefik/certs/domain.crt -text -noout

security-fail2ban-status:
	@printf "${_CYAN}Statut de Fail2Ban...${_END}"
	@docker-compose exec security fail2ban-client status
	@docker-compose exec security fail2ban-client status traefik-auth
	@printf "${_GREEN}Statut OK !${_END}"

security-pentest:
	@printf "${_CYAN}Tests de pénétration basiques...${_END}"
	@docker run --rm --network=backend securitytools/nmap -sV traefik
	@docker run --rm --network=backend securitytools/nikto -h traefik

security-firewall-status:
	@printf "${_CYAN}Statut du pare-feu...${_END}"
	@sudo ufw status verbose
	@docker-compose exec security iptables -L
	@printf "${_GREEN}Statut OK !${_END}"

security-cert-check:
	@printf "${_CYAN}Vérification des certificats...${_END}"
	@for cert in config/traefik/certs/*.crt; do \
		openssl x509 -in $$cert -text -noout | grep "Not After"; \ 
	done

security-clean:
	@printf "${_CYAN}Nettoyage des fichiers de sécurité...${_END}"
	@docker-compose exec security fail2ban-client unban --all
	@rm -f config/security/temp/*