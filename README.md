# Stack de Développement Local

Cette stack de développement est conçue pour fonctionner sur Raspberry Pi(ARM64) et fournit un environnement complet pour le développement web.

## 📋 Sommaire

- Prérequis
- Services disponibles
- Installation
- Utilisation
- Structure des Dossiers
- Accès aux services
- Commandes make
- Gestion des projets
- Sauvegarde et Restauration
- Dépannage

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

## 🚀 Services disponibles

- Serveurs Web
    - Apache + PHP 8.3
    - Node.js 20
- Bases de Données
    - MariaDB 10.3
    - PostgresSQL 16.3
    - Redis 5
- Outils d'Administration
    - PHPMyAdmin
    - PgAdmin
    - Traefik (reverse proxy)
    - MailHog (serveur SMTP de test)

## 📥 Installation
    
1.Cloner le dépot:<br>

```git
git clone <repo-url> stack-dev
cd stack-dev
```

2.Installation initiale:<br>

```
make install
```

3.Générer les certificats SSL:<br>

```
make ssl
```

4.Créér et configurer le fichier .env:<br>

```
cp .env.example .env
```

5.Démarrer les services:

```
make up
```

## 🛠 Utilisation

### Structure des Dossiers

stack-dev/<br>
├── projects/<br>
│   ├── php/        #Projets PHP<br>
│   └── node/       #Projets Node.js<br>
├── dumps/          #Sauvegardes des bases de données<br>
├── traefik/        #Configuration et certificats Traefik<br>
└── docker-compose.yml

### Accès aux services
- Sites web
    - PHP: http://php.localhost
    - Node.js: http://node.localhost
- Outils
    - PHPMyAdmin: http://phpmyadmin.localhost
    - PgAdmin: http://pgadmin.localhost
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

## 💾 Sauvegarde et restauration

### Créer une sauvegarde
```make
make backup
# Les sauvegardes sont stockées dans dumps/DATE/
```

### Restaurer une sauvegarde
```make
# Exemple: restaurer la sauvegarde du 2024-12-14-10-30-00
make restore dump=2024-12-14-10-30-00
```

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
sudo chown -R $(whoami):$(whoami) projects/
```

### 🔒 Sécurité
- Les mots de passe par défaut doivent être changés en production
- Les certificats SSL sont auto-signés (pour le développement uniquement)
- L'accès aux outils d'administration devrait être restreint en production
<hr>

Pour plus d'aide ou de documentation, consultez le Makefile (make help) ou ouvrez une issue sur le dépôt.
