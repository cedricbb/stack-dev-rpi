# Stack de Développement Local

Cette stack de développement est conçue pour fonctionner sur Raspberry Pi(ARM64) et fournit un environnement complet pour le développement web.

## 📋 Sommaire

- Fonctionnalités
- Prérequis
- Installation
- Configuration
- Utilisation
- Sécurité
- Monitoring
- Structure des Dossiers
- Accès aux services
- Commandes make
- Gestion des projets
- Sauvegarde et Restauration
- Dépannage

## 🚀 Fonctionnalités

- Environnements de développement
    - PHP 8.3 avec Apache
    - Node.js 20
    - MariaDB 10.3
    -PostgreSQL 16.3
    - Redis 5
- Outils de développement
    - VS Code Server
    - Gitlab CE
    - PHPMyAdmin
    - PgAdmin
    - MailHog
- Monitoring
    - Prometheus
    - Grafana
    - Alertmanager
    - Node Exporter
    - cAdvisor
- Sécurité
    - Traefik avec SSL
    - Fail2ban
    -AppArmor
    - UFW
    - Audit système

## ⚙️ Prérequis

- Raspberry Pi avec OS 64-bit
- Docker et Docker Compose installés
- Make installé
- Git (optionnel)

### Installation des prérequis sur Raspberry Pi

```
sudo apt-get update
sudo apt-get install -y docker.io docker-compose make git
```

## 📥 Installation
    
1.Cloner le dépot:<br>

```bash
git clone <repo-url> stack-dev
cd stack-dev
```

2.Lancer l'installation:<br>

```bash
chmod +x script/install.sh
./script/install.sh
```
L'installation configure automatiquement :
- La structure des dossiers
- Les certificats SSL
- Les réseaux Doccker
- Les permissions des dossiers
- Les variables d'environnement

## 🔧 Configuration

### Variables d'environnement

Copiez .env.example vers .env :
```bash
cp .env.example .env
```

Principales variables à configurer :
```bash
# Base de données
DATABASE_PASSWORD=votre_mot_de_passe
POSTGRES_DATABASE_PASSWORD=votre_mot_de_passe

# Monitoring
GRAFANA_PASSWORD=votre_mot_de_passe

# GitLab
GITLAB_ROOT_PASSWORD=votre_mot_de_passe
```

## 🛠 Utilisation

### Démarrage des services
```bash
make up
make status
make logs
```

### Accès aux services
- Développement
    - PHP: http://php.localhost
    - Node.js: http://node.localhost
    - VS Code : http://code.localhost
- Bases de données
    - PHPMyAdmin: http://phpmyadmin.localhost
    - PgAdmin: http://pgadmin.localhost
- Monitoring
    - Prometheus: http://prometheus.localhost
    - Grafana: http://grafana.localhost
- Outils
    - GitLab: http://gitlab.localhost
    - Traefik Dashboard: http://traefik.localhost:8080
    - MailHog: http://mailhog.localhost

### Ports par Défaut
- HTTP: 80
- HTTPS: 443
- MariaDB: 3306
- PostgreSQL: 5432
- Redis: 6379
- MailHog SMTP: 1025

## 📋 Commandes make

### gestion des services

```make
make up              #Démarrer tous les services
make down            #Arrêter tous les services
make restart         #Redémarrer tous les services
make status          #Voir l'état des services
make logs            #Voir tous les logs
make logs s=SERVICE  #Voir les logs d'un service spécifique
```

### Accès aux Shells

```make
make php-shell       #Shell PHP
make node-shell      #Shell Node.js
make mysql-shell     #Shell MySQL
make postgres-shell  #Shell PostgreSQL
```

### Sauvegarde et Restauration

```make
make backup          #Sauvegarder les bases de données
make restore dump=DATE  #Restaurer une sauvegarde
```

### Maintenance

```make
make clean           # Nettoyer tous les containers et volumes
```

## 📂 Gestions des Projets

### Projets PHP
1. placez vos fichiers dans projects/php/
2. Accédez à http://php.localhost

### Projets Node.js
1. Accédez au shell Node.js
```
make node-shell
```
2. Dans le container:
```node
cd /app
npm init
npm install
npm start
```

### 🔒 Sécurité

### Certificats SSL
```bash
make ssl
```

### Pare-feu
```bash
make security-scan
make security-update
```

## 📊 Monitoring

### Dashboards Grafana
- Docker Containers
- System Resources
- Application Metrics

### Alertes
- Configurées dans Prometheus
- Notifications via Discord/Slack

## 💾 Sauvegarde et restauration

### Créer une sauvegarde
```bash
make backup
make backup-list
make restore file=backup_name
# Les sauvegardes sont stockées dans dumps/DATE/
```

### 👨‍💻 Développement à Distance
1. Connexion via VPN
```bash
make vpn-install
make vpn-client
```
2. VS Code :
- Installer l'extension "Remote-SSH"
- Se connecter via le VPN

## 🔧 Dépannage

### Les services ne démarrent pas
```make
# Vérifier les logs
make logs

# Redémarrer un service spécifique
docker-compose restart SERVICE_NAME

# Recréer les containers
make down
make up
```

### Porblèmes de certificats SSL
```make
# Regénérer les certificats
make ssl
make restart
```

### Problèmes de permissions
```make
# Corriger les permissions des dossiers de projets
make fix-permissions
```

## 🤝  Contribution
1. Fork le projet
2. Créer une branche
3. Commit les changements
4. Push vers la branche
5. Créer une Pull Request

## 📝 License

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.
<hr>

Pour plus d'aide ou de documentation, consultez le Makefile (make help) ou ouvrez une issue sur le dépôt.
