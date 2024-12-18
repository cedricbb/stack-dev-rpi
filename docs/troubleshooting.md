# Guide de dépanage

## Diagnostic rapide

### Vérification de l état des services

```bash
# État général
make status

# Logs des services
make logs

# Santé des conteneurs
make monitor-health
```

## Problèmes courants

### 1. Servicess qui ne démarrent pas

#### Symptômes
- Container en état "Exit"
- Service inaccessible
- Erreurs dans les logs

#### Solution

```bash
# Vérifier les logs
make logs s=service-name

# Redémarrer le service
make restart s=service-name

# Recréer le conteneur
make recreate s=service-name
```

### 2.Problèmes de base de données

#### MariaDB

```bash
# Vérifier la connexion
make mysql-check

# Réparer les tables
make mysql-repair

# Optimiser
make mysql-optimize
```
#### PostgreSQL

```bash
# Vérifier la connexion
make postgres-check

# Vacuum
make postgres-vacuum
```

### 3.Problèmes de certificats SSL

#### Symptômes
- ERR_CERT_AUTHORITY_INVALID
- SSL_ERROR_BAD_CERT_DOMAIN

#### Solution

```bash
# Utilisation des ressources
make resources-check

# Profiling
make profile s=service-name
```

## Outils de diagnostic

### Commandes Docker utiles

```bash
# Inspecter un conteneur
docker inspect container_name

# Statistiques en temps réel
docker stats

# Nettoyer les ressources inutilisées
docker system prune
```

### Logs et monitoring

```bash
# Logs agrégés
make logs-all

# Métriques Prometheus
make metrics-check

# Dashboard Grafana
make grafana-check
```

## Procédures de restauration

### Restauration complète

```bash
# Arrêt propre
make down

# Nettoyage
make clean

# Restauration
make restore file=backup_name

# Redémarrage
make up
```

### Restaurationm sélective

```bash
# Base de données uniquement
make restore-db file=backup_name

# Configuration uniquement
make restore-config file=backup_name
```

## Maintenance préventive

### Vérification quotidiennes

```bash
# Santé générale
make daily-check

# Espace disque
make disk-check

# Performances
make perf-check
```

### Maintenance hebdomadaire
```bash
# Nettoyage des logs
make clean-logs

# Optimisation des bases de données
make optimize-db

# Mise à jour des images
make update-images
```

## Support et escalade

### Niveaux de support

1.Vérification basique
```bash
make diagnose
```
2.Analyse approfondie
```bash
make deep-analyze
```
3.Support avancé
```bash
make generate-report
```

### Collection d'informations

```bash
# Générer un rapport complet
make debug-report

# Collecter les logs
make collect-logs

# État du système
make system-report
```