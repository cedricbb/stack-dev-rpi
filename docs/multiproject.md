# Guide gestion Multi-Projets

## Strucure des Projets

### Organisation des Dossiers

```bash
projects/
├── php/
│   ├── project1/
│   └── project2/
├── react/
│   ├── project1/
│   └── project2/
├── next/
│   ├── project1/
│   └── project2/
├── nuxt/
│   ├── project1/
│   └── project2/
├── angular/
│   ├── project1/
│   └── project2/
└── flutter/
    ├── project1/
    └── project2/
```

## Création de Projets

### Commandes de Base

```bash
# Créer un nouveau projet
make create-project type=<type> name=<name>

# Types disponibles :
# - php
# - react
# - next
# - nuxt
# - angular
# - flutter

# Exemples :
make create-project type=react name=dashboard
make create-project type=php name=api
```

### Configuration des Ports

chaque projet utilise un port unique défini dans le fichier .emv :
```bash
# .env
REACT_PROJECT1_PORT=3000
REACT_PROJECT2_PORT=3001
NEXT_PROJECT1_PORT=3100
NEXT_PROJECT2_PORT=3101
```

### Installation des Dépendances

```bash
# Pour les projets Node.js (React, Next, Nuxt, Angular)
make npm-install project=react/project1

# Pour les projets PHP
make composer-install project=php/project1
```

### Lancement des Projets

```bash
# Démarrer un projet spécifique
make dev project=react/project1

# Arrêter un projet spécifique
make stop project=react/project1
```

### Liste des Projets

```bash
# Afficher tous les projets existants
make list-projects
```

## URLs d'Accès

### Convention de Nommage

Les projets sont accessibles via des sous-domaines basé sur leur type et nom :
- React : http://project1.react.localhost
- Next : http://project1.next.localhost
- PHP : http://project1.php.localhost

## Configuration Docker

### Example pour React
```yaml
services:
  react-project1:
    container_name: react-project1
    build:
      context: ./projects/react/project1
    volumes:
      - ./projects/react/project1:/app
    ports:
      - "${REACT_PROJECT1_PORT}:3000"
    labels:
      - "traefik.enable=true"
      - "traefik.frontend.rule=Host:project1.react.localhost"
```

## Commandes de Développement

### NPM et Composer

```bash
# Installation globale pour tous les projets d'un type
make npm-install-all type=react
make composer-install-all type=php

# Installation pour un projet spécifique
make npm-install project=react/project1
make composer-install project=php/project1
```
### Commandes de Build

```bash
# Build d'un projet spécifique
make build project=react/project1

# Build de tous les projets d'un type
make build-all type=react
```

## Maintenance

### Nettoyage

```bash
# Nettoyer les node_modules d'un projet
make clean project=react/project1

# Nettoyer tous les projets d'un type
make clean-all type=react
```

### Mises à jour

```bash
# Mettre à jour les dépendances d'un projet
make update project=react/project1

# Mettre à jour tous les projets d'un type
make update-all type=react
```
## Bonnes Pratiques

### 1.Nommage des Projets

- Utiliser des noms descriptifs
- Éviter les espaces et caractères spéciaux
- Préfer le kebab-case (ex: my-project)

### 2.Gestion des Ports

- Réserver des plages de ports par type de projet
- React : 3000-3099
- Next : 3100-3199
- PHP : 8000-8099
- Nuxt : 3100-3199
- Angular : 3200-3299

### 3. Organisation du code

- Chaque projet doit avoir son propre .gitignore
- Gérer les dépendances au niveau projet
- Documenter les spécifités dans un README.md

### 4.Sécurité
- Ne pas partager les variables d'environnement entre projets
- Utiliser des .env spécifiques par projet
- Isoler les bases de données

## Dépannage

### Problèmes Courants

#### 1.Conflit de Ports
```bash
# Vérifier les ports utilisés
make list-ports

# Changer le port d'un projet
make change-port project=react/project1 port=3001
```

#### 2.Problèmes de Dépendances
```bash
# Nettoyer et réinstaller
make clean project=react/project1
make npm-install project=react/project1
```

### Logs et Debugging
```bash
# Voir les logs d'un projet spécifique
make logs project=react/project1

# Debug mode
make dev project=react/project1 debug=true
```