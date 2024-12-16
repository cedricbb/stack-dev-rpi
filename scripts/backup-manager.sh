#!/bin/bash

# Configuration
BACKUP_ROOT="/backups"
MAX_BACKUPS=7
BACKUP_FORMAT="%Y-%m-%d-%H-%M"
DATABASES=("mariadb" "postgres", "gitlab")
VOLUMES=("gitlab_config" "gitlab_data" "portainer_data" "grafana_data")

# Fonction de backup des bases de données
backup_databases() {
    local timestamp=$(date +${BACKUP_FORMAT})
    local backup_dir="${BACKUP_ROOT}/${timestamp}/databases"
    
    mkdir -p "$backup_dir"
    
    # MariaDB
    docker exec mariadb mysqldump -u root -p"${DATABASE_PASSWORD}" --all-databases > "${backup_dir}/mariadb_backup.sql"
    
    # PostgreSQL
    docker exec postgres pg_dumpall -U postgres > "${backup_dir}/postgres_backup.sql"
    
    # Compression
    cd "${backup_dir}" && tar czf "../databases.tar.gz" .
    rm -rf "${backup_dir}"
}

# Fonction de backup des volumes
backup_volumes() {
    local timestamp=$(date +${BACKUP_FORMAT})
    local backup_dir="${BACKUP_ROOT}/${timestamp}/volumes"
    
    mkdir -p "$backup_dir"
    
    for volume in "${VOLUMES[@]}"; do
        docker run --rm \
            -v "$volume":/source:ro \
            -v "$backup_dir":/backup \
            alpine tar czf "/backup/${volume}.tar.gz" -C /source ./
    done
    
    # Compression finale
    cd "${backup_dir}" && tar czf "../volumes.tar.gz" .
    rm -rf "${backup_dir}"
}

# Fonction de rotation des sauvegardes
rotate_backups() {
    local backup_count=$(ls -1 "${BACKUP_ROOT}" | wc -l)
    
    if [ "$backup_count" -gt "$MAX_BACKUPS" ]; then
        local excess=$((backup_count - MAX_BACKUPS))
        ls -1t "${BACKUP_ROOT}" | tail -n "$excess" | xargs -I {} rm -rf "${BACKUP_ROOT}/{}"
    fi
}

# Fonction de restauration
restore_backup() {
    local backup_date=$1
    local backup_dir="${BACKUP_ROOT}/${backup_date}"
    
    if [ ! -d "$backup_dir" ]; then
        echo "Backup not found: ${backup_date}"
        exit 1
    fi
    
    # Restauration des bases de données
    tar xzf "${backup_dir}/databases.tar.gz" -C /tmp
    docker exec -i mariadb mysql -u root -p"${DATABASE_PASSWORD}" < /tmp/mariadb_backup.sql
    docker exec -i postgres psql -U postgres < /tmp/postgres_backup.sql
    
    # Restauration des volumes
    tar xzf "${backup_dir}/volumes.tar.gz" -C /tmp
    for volume in "${VOLUMES[@]}"; do
        docker run --rm \
            -v "$volume":/target \
            -v /tmp:/source \
            alpine sh -c "rm -rf /target/* && tar xzf /source/${volume}.tar.gz -C /target"
    done
    
    rm -rf /tmp/*.sql /tmp/*.tar.gz
}

# Fonction principale
main() {
    case "$1" in
        "backup")
            backup_databases
            backup_volumes
            rotate_backups
            ;;
        "restore")
            if [ -z "$2" ]; then
                echo "Please specify backup date"
                exit 1
            fi
            restore_backup "$2"
            ;;
        *)
            echo "Usage: $0 {backup|restore BACKUP_DATE}"
            exit 1
            ;;
    esac
}

main "$@"