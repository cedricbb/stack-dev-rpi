#1/bin.bash
# install.sh

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Vérification des prérequis
check_prerequisites() {
    log "Vérification des prérequis..."
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        error "Docker n'est pas installé. Installation..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
    fi

    # Vérifier Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose n'est pas installé. Installation..."
        sudo apt-get update
        sudo apt-get install -y docker-compose
    fi

    # Vérifier make
    if ! command -v make &> /dev/null; then
        error "make n'est pas installé. Installation..."
        sudo apt-get install -y make
    fi
}

# Création de la structure des dossiers
create_directory_structure() {
    log "Création de la structure des dossiers..."
    
    directories=(
        "config/prometheus"
        "config/grafana/provisioning/dashboards"
        "config/grafana/provisioning/datasources"
        "config/traefik/certs"
        "config/fail2ban"
        "config/nginx"
        "projects/php"
        "projects/node"
        "backups"
        "logs"
        "dumps"
    )

    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        log "Création de $dir"
    done
}

# Configuration des permissions
setup_permissions() {
    log "Configuration des permissions..."

    # Permissions pour les dossiers de projet
    sudo chown -R "${USER}:${USER}" projects/
    sudo chmod -R 775 projects/

    # Permissions pour les certificats
    sudo chown -R "${USER}:${USER}" config/traefik/certs/
    sudo chmod -R 775 config/traefik/certs/
}

# Configuration du réseau Docker
setup_docker_network() {
    log "Configuration du réseau Docker..."

    if ! docker network inspect backend >/dev/null 2>&1; then
        docker network create backend
        log "Réseau 'backend' créé."
    else
        warning "Le réseau 'backend' existe déjà."
    fi
}

# Configuration de l'environnement
setup_environment() {
    log "Configuration de l'environnement..."

    if [ ! -f .env ]; then
        cp .env.example .env
        log "Fichier .env créé à partir de .env.example"

        # Génération de mots de passe aléatoires
        DB_PASSWORD=$(openssl rand -base64 32)
        GRAFANA_PASSWORD=$(openssl rand -base64 32)
        GITLAB_ROOT_PASSWORD=$(openssl rand -base64 32)

        # Mise à jour du fichier .env
        sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" .env
        sed -i "s/GRAFANA_PASSWORD=/GRAFANA_PASSWORD=$GRAFANA_PASSWORD/" .env
        sed -i "s/GITLAB_ROOT_PASSWORD=/GITLAB_ROOT_PASSWORD=$GITLAB_ROOT_PASSWORD/" .env
    else
        warning "Le fichier .env existe déjà."
    fi
}

# Installation des certificats SSL
setup_ssl() {
    log "Installation des certificats SSL..."

    if  [ ! -f config/traefik/certs/domain.crt ]; then
        chmod +x scripts/ssl.sh
        ./scripts/ssl.sh
        log "Certificats SSL générés avec succès."
    else
        warning "Les certificats SSL existent déjà."
    fi
}

# Installation des services
install_services() {
    log "Installation des services..."

    # Démarrage des services
    make up

    # Vérification de l'état des services
    sleep 10
    make status
}

# Fonction principale
main() {
    log "Début de l'installation..."

    check_prerequisites
    create_directory_structure
    setup_permissions
    setup_docker_network
    setup_environment
    setup_ssl
    install_services

    log "Installation terminée."
    log "Accédez à http://traefik.localhost pour accéder à Traefik Dashboard."
    log "les mots de passe générés sont dans le fichier .env"
}

# Éxécution du script
main
