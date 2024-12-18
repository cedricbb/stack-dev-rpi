# Guide d'Installation - Stack de Développement Complète

## 📋 Sommaire

1. Prérequis
2. Installation initiale
3. Strucutre des dossiers
4. Configuration
5. Services de développement
6. Configuration du monitoring
7. Sécurité
8. Vérification

## Prérequis

```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation des dépendances
sudo apt install -y \
    docker.io \
    docker-compose \
    make \
    git \
    curl \
    openssl

# Ajout de l'utilisateur au groupe docker
sudo usermod -aG docker $USER
newgrp docker
```

## Installation initiale

1. Clone du dépot :
```bash
git clone <repo-url> stack-dev
cd stack-dev
```
2. Céation de la strucutre des dossiers :
```bash
# Dossiers principaux
mkdir -p \
    config/{prometheus,grafana,traefik/certs,fail2ban,nginx,php,mariadb,postgres,redis} \
    projects/{php,node,react,next,nuxt,angular,flutter} \
    backups \
    logs/{traefik,nginx,fail2ban} \
    data/{grafana,prometheus,gitlab,portainer} \
    docs

# Dossiers de monitoring
mkdir -p \
    config/prometheus/rules \
    config/grafana/provisioning/{dashboards,datasources} \
    config/node-exporter
```
3. Configuration des permissions :
```bash
# Permissions des certificats
chmod 700 config/traefik/certs
touch config/traefik/certs/.gitkeep

# Permissions des scripts
chmod +x scripts/*.sh
```

## Configuration

1. Configuration de l'environnement :
```bash
# Copie du fichier d'exemple
cp .env.example .env

# Génération des mots de passe
make generate-passwords
```
2. Création du réseau Docker :
```bash
docker network create backend
```
3. Génération des certificats SSL :
```bash
make ssl
```

## Services de développement
    
1.Démarrage des services de base :
```bash
# Démarrage de tous les services
make up

# Vérification des services
make status
```
2.Configuration des bases de données 
```bash
# MariaDB
docker exec -i mariadb mysql -u root -p${DATABASE_PASSWORD} <<EOF
CREATE DATABASE IF NOT EXISTS dev_db;
GRANT ALL PRIVILEGES ON dev_db.* TO 'dev_user'@'%' IDENTIFIED BY '${DATABASE_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# PostgreSQL
docker exec -i postgres psql -U postgres <<EOF
CREATE DATABASE dev_db;
CREATE USER dev_user WITH ENCRYPTED PASSWORD '${POSTGRES_DATABASE_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE dev_db TO dev_user;
EOF
```

## Configuration du monitoring

1. Installation de Node Exporter :
```bash
# Téléchargement et installation
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-arm64.tar.gz
tar xvfz node_exporter-*.tar.gz
sudo mv node_exporter-*/node_exporter /usr/local/bin/

# Configuration du service
sudo cp config/node-exporter/node-exporter.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
```

2.Application des configurations :
```bash
make apply-config
```

## Sécurité

1. Configuration de Fail2ban :
```bash
sudo apt install -y fail2ban
sudo cp config/fail2ban/jail.local /etc/fail2ban/jail.local
sudo systemctl restart fail2ban
```
2. Configuration du pare-feu :
```bash
sudo apt install -y ufw
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

### Création d'un nouveau projet
1.React :
```bash
cd projects/react
npx create-react-app my-app

# ou
npx create-vite my-app
docker-compose up react-dev -d
```
2.Next.js :
```bash
cd projects/next
npx create-next-app my-next-app
docker-compose up next-dev -d
```
3.Nuxt :
```bash
cd projects/nuxt
npx nuxi init my-nuxt-app
docker-compose up nuxt-dev -d
```
4.Angular :
```bash
cd projects/angular
npx @angular/cli new my-angular-app
docker-compose up angular-dev -d
```
5.Flutter :
```bash
cd projects/flutter
flutter create my-flutter-app
docker-compose up flutter-dev -d
```

## Vérification

1.Test des services :
```bash
# Test complet
make test-all

# Tests spécifiques
make test-services
make test-security
make test-monitoring
```
2. Accès aux interfaces :
```bash
- Traefik : https://traefik.localhost
- Grafana : https://grafana.localhost
- PHPMyAdmin : https://phpmyadmin.localhost
- Portainer : https://portainer.localhost
- React : http://react.localhost
- Next.js : http://next.localhost
- Nuxt : http://nuxt.localhost
- Angular : http://angular.localhost
- Flutter : http://flutter.localhost
```

### Commandes utiles
```bash
# Démarrage/Arrêt
make up              # Démarrer tous les services
make down            # Arrêter tous les services
make restart         # Redémarrer tous les services

# Monitoring
make monitor-health  # Vérifier la santé des services
make logs           # Voir les logs

# Backup
make backup         # Créer une sauvegarde
make backup-list    # Lister les sauvegardes
make restore file=backup_name  # Restaurer une sauvegarde
```

### Maintenance

1. Mise à jour des services :
```bash
make update
```
2. Nettoyage :
```bash
make clean
```