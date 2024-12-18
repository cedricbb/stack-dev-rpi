# Guide de Configuration de la Stack

## Variables d'environnement

### Fichier .env

```bash
# Base de données
DATABASE_NAME=devdb
DATABASE_PASSWORD=<généré>
POSTGRES_DATABASE_NAME=postgresdb
POSTGRES_DATABASE_PASSWORD=<généré>

# Ports
DATABASE_EXTERNAL_PORT=3306
POSTGRES_DATABASE_EXTERNAL_PORT=5432
REACT_PORT=3000
NEXT_PORT=3001
NUXT_PORT=3002
ANGULAR_PORT=4200
FLUTTER_PORT=8090

# Monitoring
GRAFANA_PASSWORD=<généré>
PROMETHEUS_RETENTION=15d

# Sécurité
GITLAB_ROOT_PASSWORD=<généré>
```

## Services principaux

### Bases de données

#### MariaDB :
```ini
# config/mariadb/my.cnf
[mysqld]
innodb_buffer_pool_size = 256M
max_connections = 100
```
#### PostgreSQL :
```ini
# config/postgres/postgresql.conf
max_connections = 100
shared_buffers = 128MB
```
### Web Serveurs

#### Nginx :
```nginx
# config/nginx/security-headers.conf
add_header X-Frame-Options "SAMEORIGIN";
add_header X-XSS-Protection "1; mode=block";
```
#### Traefik :
```toml
# config/traefik/traefik.toml
[entryPoints.https]
address = ":443"
```

### Frameworks de développement

#### React/Next.js/Nuxt :
```yaml
# Exemple de configuration package.json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  }
}
```
#### Angular :
```json
# angular.json
{
  "projects": {
    "app": {
      "architect": {
        "serve": {
          "options": {
            "host": "0.0.0.0"
          }
        }
      }
    }
  }
}
```

## Monitoring

#### Prometheus :
```yaml
# config/prometheus/prometheus.yml
scrape_configs:
  - job_name: 'docker'
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
```
#### Grafana :
```ini
# config/grafana/grafana.ini
[auth]
disable_login_form = false
``` 

## Configuration des conteneurs

### Limites de ressources

```yaml
# docker-compose.yml
services:
  webapp:
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
```

### Optimisation des performances

#### Cache
```yaml
services:
  redis:
    image: redis:alpine
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
```
#### Volumes
```yaml
volumes:
  - type: volume
    source: data
    target: /data
    volume:
      nocopy: true
```