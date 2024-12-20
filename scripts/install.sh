#!/bin/bash

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Fonction pour afficher les messages
log() {
    echo -e "${CYAN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Vérification des prérequis
check_prerequisites() {
    log "Vérification des prérequis..."
    
    # Vérifier si l'utilisateur a les droits sudo
    if ! sudo -v; then
        error "Les droits sudo sont requis pour l'installation"
    fi

    # Liste des paquets requis
    packages=(docker.io docker-compose make git curl)
    
    # Vérification et installation des paquets manquants
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            log "Installation de $pkg..."
            sudo apt-get update
            sudo apt-get install -y "$pkg"
        fi
    done

    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        error "Docker n'a pas pu être installé"
    fi

    # Ajouter l'utilisateur au groupe docker
    if ! groups | grep -q docker; then
        log "Ajout de l'utilisateur au groupe docker..."
        sudo usermod -aG docker $USER
        warning "Vous devrez vous déconnecter et vous reconnecter pour que les changements prennent effet"
    fi

    success "Tous les prérequis sont installés"
}

# Création de la structure des dossiers
create_directory_structure() {
    log "Création de la structure des dossiers..."
    
    directories=(
        "make"
        "config/prometheus"
        "config/grafana/provisioning/dashboards"
        "config/grafana/provisioning/datasources"
        "config/traefik/certs"
        "config/fail2ban"
        "config/nginx"
        "config/phpmyadmin"
        "projects/php"
        "projects/node"
        "projects/react"
        "projects/next"
        "projects/nuxt"
        "projects/angular"
        "projects/flutter"
        "backups"
        "logs/traefik"
        "logs/nginx"
        "logs/fail2ban"
        "data/grafana"
        "data/prometheus"
        "data/gitlab"
        "data/portainer"
    )

    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        log "Création de $dir"
    done

    success "Structure des dossiers créée"
}

# Configuration des fichiers Make
# setup_make_files() {
#     log "Configuration des fichiers Make..."

#     # Création des fichiers Make
#     make_modules=(
#         "colors"
#         "config"
#         "services"
#         "database"
#         "monitoring"
#         "security"
#         "backup"
#         "maintenance"
#         "dev"
#     )

#     for module in "${make_modules[@]}"; do
#         touch "make/${module}.mk"
#         log "Création de make/${module}.mk"
#     done

#     # Copie des contenus des fichiers Make depuis les templates
#     # Note: Les templates doivent être créés séparément
#     success "Fichiers Make configurés"
# }

# Génération du fichier .env
generate_env_file() {
    log "Génération du fichier .env..."
    
    if [ -f .env ]; then
        warning "Le fichier .env existe déjà. Sauvegarde de l'ancien fichier..."
        mv .env .env.backup.$(date +%Y%m%d_%H%M%S)
    fi

    # Générer des mots de passe aléatoires
    DB_PASSWORD=$(openssl rand -base64 32)
    GITLAB_PASSWORD=$(openssl rand -base64 32)
    CODE_SERVER_PASSWORD=$(openssl rand -base64 32)

    cat > .env << EOF
# Passwords
DATABASE_PASSWORD=${DB_PASSWORD}
POSTGRES_DATABASE_PASSWORD=${DB_PASSWORD}
GITLAB_ROOT_PASSWORD=${GITLAB_PASSWORD}
CODE_SERVER_PASSWORD=${CODE_SERVER_PASSWORD}

# Ports
REACT_PORT=3000
NEXT_PORT=3001
NUXT_PORT=3002
ANGULAR_PORT=4200
FLUTTER_PORT=8090
PGADMIN_PORT=5050

# WordPress Keys and Salts
AUTH_KEY='$(openssl rand -base64 48)'
SECURE_AUTH_KEY='$(openssl rand -base64 48)'
LOGGED_IN_KEY='$(openssl rand -base64 48)'
NONCE_KEY='$(openssl rand -base64 48)'
AUTH_SALT='$(openssl rand -base64 48)'
SECURE_AUTH_SALT='$(openssl rand -base64 48)'
LOGGED_IN_SALT='$(openssl rand -base64 48)'
NONCE_SALT='$(openssl rand -base64 48)'
EOF

    success "Fichier .env généré"
}

# Configuration du réseau Docker
setup_docker_network() {
    log "Configuration du réseau Docker..."
    
    if ! docker network ls | grep -q "backend"; then
        docker network create backend
        success "Réseau 'backend' créé"
    else
        warning "Le réseau 'backend' existe déjà"
    fi
}

# Installation des certificats SSL
setup_ssl() {
    log "Configuration des certificats SSL..."
    
    if [ ! -f "config/traefik/certs/domain.crt" ]; then
        bash scripts/ssl.sh
        success "Certificats SSL générés"
    else
        warning "Les certificats SSL existent déjà"
    fi
}

# Installation des services
install_services() {
    log "Installation des services..."
    
    make up
    sleep 5
    make status

    success "Services installés"
}

setup_base_services() {
    log "Configuration des services de base..."
    
    # S'assurer que le docker-compose.yml existe
    if [ ! -f "docker-compose.yml" ]; then
        error "docker-compose.yml manquant"
    fi

    # Vérifier que les services de base sont présents dans docker-compose.yml
    required_services=("traefik" "phpmyadmin" "mariadb" "postgres")
    for service in "${required_services[@]}"; do
        if ! grep -q "^[[:space:]]*$service:" docker-compose.yml; then
            error "Service $service manquant dans docker-compose.yml"
        fi
    done

    log "Démarrage des services de base..."
    # Pull des images nécessaires
    docker-compose pull traefik phpmyadmin mariadb postgres

    success "Services de base configurés"
}

# Fonction principale
main() {
    log "Début de l'installation..."
    
    check_prerequisites
    create_directory_structure
    # setup_make_files
    generate_env_file
    setup_docker_network
    setup_ssl
    setup_base_services
    install_services
    
    success "Installation terminée avec succès!"
    
    if ! groups | grep -q docker; then
        warning "IMPORTANT: Déconnectez-vous et reconnectez-vous pour que les changements de groupe Docker prennent effet"
    fi

    log "Accédez à http://traefik.localhost pour voir le dashboard Traefik"
    log "Les mots de passe générés sont dans le fichier .env"
}

# Exécution du script
main