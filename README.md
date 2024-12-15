### Stack de Développement Local

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

# Installation des prérequis sur Raspberry Pi
sudo apt-get update
sudo apt-get install -y docker.io docker-compose make git

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
    
    1.Cloner le dépot:

    git clone <repo-url> stack-dev
    cd stack-dev

    2.Installation initiale:

    make install

    3.Générer les certificats SSL:

    make ssl

    4.Créér et configurer le fichier .env:

    cp .env.example .env

    5.Démarrer les services:

    make up

## 🛠 Utilisation

## Structure des Dossiers

stack-dev/
├── projects/
│   ├── php/        # Projets PHP
│   └── node/       # Projets Node.js
├── dumps/          # Sauvegardes des bases de données
├── traefik/        # Configuration et certificats Traefik
└── docker-compose.yml

## Accès aux services
    - Sites web
        - PHP: http://php.localhost
        - Node.js: http://node.localhost
    - Outils
        - PHPMyAdmin: http://phpmyadmin.localhost
        - PgAdmin: http://pgadmin.localhost
        - Traefik Dashboard: http://traefik.localhost:8080
        - MailHog: http://mailhog.localhost

## Ports par Défaut
    - HTTP: 80
    - HTTPS: 443
    - MariaDB: 3306
    - PostgreSQL: 5432
    - Redis: 6379
    - MailHog SMTP: 1025

## 📋 Commandes make

## gestion des services

make up              # Démarrer tous les services
make down            # Arrêter tous les services
make restart         # Redémarrer tous les services
make status          # Voir l'état des services
make logs            # Voir tous les logs
make logs s=SERVICE  # Voir les logs d'un service spécifique

## Accès aux Shells

make php-shell       # Shell PHP
make node-shell      # Shell Node.js
make mysql-shell     # Shell MySQL
make postgres-shell  # Shell PostgreSQL

## Sauvegarde et Restauration

make backup          # Sauvegarder les bases de données
make restore dump=DATE  # Restaurer une sauvegarde

## Maintenance

make clean           # Nettoyer tous les containers et volumes

## 📂 Gestions des Projets

## Projets PHP
    1. placez vos fichiers dans projects/php/
    2. Accédez à http://php.localhost