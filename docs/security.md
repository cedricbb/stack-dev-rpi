# Guide Sécurité

## Architecture de sécurité

### Composants principaux

- Traefik : Reverse Proxy sécurisé
- Fail2ban : Protection contre les attaques par force brute
- SSL/TLS : Certificats pour le chiffrement
- AppArmor : Protection des conteneurs
- UFW : Pare-feu

## Configuration SSL/TLS

### Génération des certificats

```bash
# Génération manuelle
make ssl

# Renouvellement
make ssl-renew
```

### Configuration de Traefik

```toml
# config/traefik/traefik.toml
[entryPoints.https.tls]
  [[entryPoints.https.tls.certificates]]
    certFile = "/etc/traefik/certs/domain.crt"
    keyFile = "/etc/traefik/certs/domain.key.pem"
```

## Protection contre les intrusions

### Fail2ban

#### 1.Configuration globale :

```ini
# config/fail2ban/jail.local
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5
```

#### 2.Protection SSH :

```ini
[sshd]
enabled = true
port = ssh
filter = sshd
maxretry = 3
```

#### 3.Protection Traefik :

```ini
[traefik-auth]
enabled = true
port = http,https
filter = traefik-auth
maxretry = 5
```

### Pare-feu (UFW)

#### AppArmor :

```yaml
# docker-compose.yml
security_opt:
  - apparmor=docker-default
```
#### Limites des ressources :
```yaml
services:
  webapp:
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
    security_opt:
      - no-new-privileges
```

### Gestion des secrets

#### Variables d'environnement :

- Utiliser .env pour les secrets
- Ne jamais commiter .env
- Utiliser .env.examplecomme template

#### Vault (optionnel) :

```bash
# Installation
make vault-install

# Configuration
make vault-config
```

## Sécurité des applications

### Headers HTTP

```nginx
# config/nginx/security-headers.conf
add_header X-Frame-Options "SAMEORIGIN";
add_header X-XSS-Protection "1; mode=block";
add_header X-Content-Type-Options "nosniff";
add_header Content-Security-Policy "default-src 'self'";
```

### CORS

```yaml
# Traefik configuration
headers:
  customResponseHeaders:
    Access-Control-Allow-Origin: "trusted-domain.com"
```

### Audit et Logging

#### Logs système :

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

#### Audit des accès :

```bash
# Vérification des logs
make audit-logs

# Rapport de sécurité
make security-report
```

## Procédures de sécurité

### Vérification régulières

1. Mise à jour des composants :
```bash
make security-update
```
2. Scan de vulnérabilités :
```bash
make security-scan
```
3. Tests de pénétration :
```bash
make pentest
```

### Réponse aux incidents

1. Isolation du service compromis :
```bash
make service-isolate s=service-name
```
2. Analyse des logs :
```bash
make security-analyze
```
3. Restauration sécurisée :
```bash
make secure-restore
```