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

# Vérification du deploiement
check_deployment() {
    local max_attempts=30
    local attempt=1

    echo "Checking deployment..."

    while [ $attempt -le $max_attempts ]; do
        if docker-compose ps | grep -q "Exit"; then
            echo "Deployment failed. Check logs."
            return 1
        fi

        if [ $attempt -eq $max_attempts ]; then
            echo "All services are running."
            return 0
        fi

        sleep 2
        ((attempt++))
    done
}

# Notification de déploiement
notify_deployment() {
    local environment=$1
    local version=$2
    local webhook_url=${DISCORD_WEBHOOK_URL}

    if [ -n "$webhook_url" ]; then
    curl -H "Content-type: application/json" \
        -d "{\"content\": \"🚀 Deployment complete\\nEnvironment: ${environment}\\nVersion: ${version}\"}" \
        "$webhook_url"
    fi
}

# Rollback en cas d'échec
rollback() {
    local environment=$1
    local previous_version=$2

    echo "Rolling back to previous version: ${previous_version}..."

    docker-compose -f "docker-compose.${environment}.yml" down
    docker tag "$CI_REGISTRY_IMAGE:$previous_version" "$CI_REGISTRY_IMAGE:latest"
    docker-compose -f "docker-compose.${environment}.yml" up -d
}

# fonction principale
main() {
    case "$1" in
        "deploy")
            deploy "$2" "$3"
            ;;
        "rollback")
            rollback "$2" "$3"
            ;;
        *)
            echo "Usage: $0 {deploy|rollback} <environment> <version>"
            exit 1
            ;;
    esac
}

main "$@"