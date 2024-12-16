#!/bin/bash

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW=' \033[1;33m'
NC='\033[0m'

# Fonction pour tester un service HTTP
test_http_service() {
    local service_name=$1
    local url=$2
    local expected_code=$3

    echo -e "${YELLOW}Testing $service_name...${NC}"
    response=$(curl -s -o /dev/null -w "%{http_code}" -k "$url")

    if [ "$response" == "$expected_code"]; then
        echo -e "${GREEN}✓ $service_name is running (HTTP $response)${NC}"
        return 0
    else
        echo -e "${RED}✗ $service_name failed (HTTP $response)${NC}"
        return 1
    fi
}

# Fonction pour tester une bqse de données
test_database() {
    local db_type=$1
    local host=$2
    local port=$3
    local user=$4
    local password=$5

    echo -e "${YELLOW}Testing $db_type connection...${NC}"

    case $db_type in
        "mysql")
            if mysql -h "$host" -P "$port" -u "$user" -p"$password" -e "SELECT 1" &>/dev/null; then
                echo -e "${GREEN}✓ MySQL connection successful${NC}"
                return 0
            else
                echo -e "${RED}✗ MySQL connection failed${NC}"
                return &
            fi
            ;;
        "postgres")
            if PGPASSWORD=$password psql -h "$host" -p "$port" -U "$user" -c "SELECT 1" &>/dev/null; then
                echo -e "${GREEN}✓ PostgreSQL connection successful${NC}"
                return 0
            else
                echo -e "${RED}✗ PostgreSQL connection failed${NC}"
                return &
            fi
            ;;
    esac
}

# Tester Docker et le réseau
test_docker() {
    echo -e "${YELLOW}Testing Docker setup...${NC}"

    # Vérifier que Docker fonctionne
    if docker info &>/dev/null; then
        echo -e "${GREEN}✓ Docker is running${NC}"
    else
        echo -e "${RED}✗ Docker is not running${NC}"
        exit 1
    fi

    # Vérifier le réseau backend
    if docker network inspect backend &>/dev/null; then
        echo -e "${GREEN}✓ Docker network backend is running${NC}"
    else
        echo -e "${RED}✗ Docker network backend is not running${NC}"
        exit 1
    fi
}

# Tester le monitoring
test_monitoring() {
    echo -e "${YELLOW}Testing monitoring services...${NC}"

    # Test Prometheus
    test_http_service "Prometheus" "http://prometheus.localhost" 200

    # Test Grafana
    test_http_service "Grafana" "http://grafana.localhost" 200

    # Vérifier les métriques
    if curl -s "http://prometheus.localhost/api/v1/query?query=up" | grep -q "succes"; then
        echo -e "${GREEN}✓ Prometheus metrics available${NC}"
    else
        echo -e "${RED}✗ Prometheus metrics not available${NC}"
    fi
}

# Tester la sécurité
test_security() {
    echo -e "${YELLOW}Testing security configuration...${NC}"

    # Test SSL
    if curl -sI https://traefik.localhost  -k | grep -q "200 OK"; then
        echo -e "${GREEN}✓ SSL is configured${NC}"
    else
        echo -e "${RED}✗ SSL configuration failed${NC}"
    fi

    # Test Fail2Ban
    if sudo fail2ban-client status | grep -q "Number of jail"; then
        echo -e "${GREEN}✓ Fail2Ban is running${NC}"
    else
        echo -e "${RED}✗ Fail2Ban is not running${NC}"
    fi
}

# tester les services de développement
test_dev_services() {
    echo -e "${YELLOW}Testing development services...${NC}"

    # Test VS Code Server
    test_http_service "VS Code Server" "https://code.localhost" 200

    # Test GitLab
    test_http_service "GitLab" "https://gitlab.localhost" 302

    # Test PHP
    test_http_service "PHP" "https://php.localhost" 200

    # Test Node.js
    test_http_service "Node.js" "https://node.localhost" 200
}

# Fonction principale
main() {
    echo "Starting service tests..."

    test_docker
    test_monitoring
    test_security
    test_dev_services

    test_database "mysql" "localhost" "3306" "root" "${DATABASE_PASSWORD}"
    test_database "postgres" "localhost" "5432" "postgres" "${POSTGRES_DATABASE_PASSWORD}"

    echo -e "\nAll tests completed!"
}

# Exécution
main