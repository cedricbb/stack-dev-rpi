#!/bin/bash

# Configuration
DEPLOY_ROOT="/var/www"
BACKUP_BEFORE_DEPLOY=true
NOTIFY_ON_DEPLOY=true

# Fonction de déploiement
deploy() {
    local environment=$1
    local version=$2

    echo "Deploying ${environment} version ${version}"

    # Backup avant déploiement
    if [ "$BACKUP_BEFORE_DEPLOY" = true ]; then
        ./backup-manager.sh backup
    fi

    # Arrêt des services
    docker-compose -f "docker-compose.${environment}.yml" down

    # Mise à jour des images Docker
    docker-compose -f "docker-compose.${environment}.yml" pull

    # Démarrage des services
    docker-compose -f "docker-compose.${environment}.yml" up -d

    # Vérfication post-déploiement
    check_deployment

    # Notification
    if [ "$NOTIFY_ON_DEPLOY" = true ]; then
        notify_deployment "$environment" "$version"
    fi
}