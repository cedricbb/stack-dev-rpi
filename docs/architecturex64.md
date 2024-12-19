# Modifications pour Architecture X64

### 1.Docker Compose - changement d'Images

```yaml
services:
  # Remplacer les images arm64v8 par leurs équivalents x64
  mariadb:
    # De : image: arm64v8/mariadb:10.3
    image: mariadb:10.3

  postgres:
    # De : image: arm64v8/postgres:16.3-alpine
    image: postgres:16.3-alpine

  redis:
    # De : image: arm64v8/redis:5-alpine
    image: redis:5-alpine

  traefik:
    # De : image: arm64v8/traefik:1.7.20
    image: traefik:1.7.20

  phpmyadmin:
    # De : image: arm64v8/phpmyadmin:latest
    image: phpmyadmin:latest

  php:
    # De : image: arm64v8/php:${PHP_VERSION}-fpm
    image: php:${PHP_VERSION}-fpm

  node:
    # De : image: arm64v8/node:20
    image: node:20
```

### 2.Points à vérifier

#### Performance

```yaml
services:
  mariadb:
    # Ajuster les limites de ressources pour x64
    deploy:
      resources:
        limits:
          memory: 1G  # Plus de mémoire disponible sur x64
        reservations:
          memory: 512M

  php:
    # Ajuster la configuration PHP
    environment:
      PHP_MEMORY_LIMIT: 256M  # Peut être augmenté sur x64
```
#### Extensions et Dépendances

```dockerfile
# Dans Dockerfile PHP
# Les extensions peuvent avoir des noms légèrement différents
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    && docker-php-ext-install zip pdo pdo_mysql

# Dans Dockerfile Node
# Certains packages natifs peuvent nécessiter une recompilation
RUN npm rebuild node-sass  # Si utilisé
```

### 3.Configuration à ne pas modifier

- Structure des dossiers
- Configuration Traefik
- Configuration des réseaux Docker
- Configuration SSL
- Scripts Make
- Structure des projets

### 4.Performances supplémentaires (optionnel)
```yaml
services:
  # Ajouter des optimisations x64
  mariadb:
    command: 
      - --innodb-buffer-pool-size=1G
      - --innodb-buffer-pool-instances=4

  postgres:
    command:
      - "postgres"
      - "-c"
      - "shared_buffers=256MB"
      - "-c"
      - "max_connections=200"

  redis:
    command: redis-server --maxmemory 512mb
```

### 5.Variables d'environnement spécifiques
```bash
# .env
# Ajuster selon l'architecture
PHP_MEMORY_LIMIT=256M
NODE_OPTIONS=--max-old-space-size=4096
POSTGRES_SHARED_BUFFERS=256MB
MARIADB_INNODB_BUFFER_POOL_SIZE=1G
```

### 6.Optimisation Docker

```yaml
# docker-compose.yml
version: "3.8"  # Peut utiliser une version plus récente sur x64

services:
  # Ajouter des optimisations générales
  mariadb:
    cpu_count: 4
    mem_limit: 2g
    memswap_limit: 2g
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
```