# Guide Backup et Restauration

## Système de backup

### Configuration des backups

Le système de backup est configuré pour sauvegarder :
- Les bases de données (MariaDB, PostgreSQL)
- Les volumes Docker
- Les fichiers de configuration
- Les certificats SSL

### Planification des backups

Par défaut, les back-ups sont exécutés :
- Quotidiennement à 2h du matin
- Conservation des 7 derniers jours
- Rotation automatique des anciennes sauvegardes

### Commandes disponbiles

```bash
# Créer une sauvegarde manuelle
make backup

# Lister les sauvegardes disponibles
make backup-list

# Restaurer une sauvegarde spécifique
make restore file=2024-12-16-02-00

# Vérifier l'intégrité des sauvegardes
make backup-verify
```

## Restauration

### Procédure de restauration complète

1. Arrêter tous les services :
```bash
make down
```
2. Restaurer les données :
```bash
make restore file=<backup-name>
```
3. Redémarrer les services :
```bash
make up
```

### Restauration sélective

Pour restaurer un service spécifique :
```bash
# Base de données uniquement
make restore-db file=<backup-name>

# Volumes uniquement
make restore-volumes file=<backup-name>

# Configuration uniquement
make restore-config file=<backup-name>
```

## Bonnes pratiques

1. Vérification des backups :
- Tester régulièrement la restauration
- Vérifier l'intégrité des fichiers
- Surveiller l'espace disque
2. Sécurité :
- Chiffrement des sauvegardes sensibles
- Stockage externe des sauvegardes importantes
- Rotation régulière des anciennes sauvegardes
3. Documentation :
- Noter les modifications de configuration
- Documenter les procédures de restauration spécifiques
- Maintenir un journal des restaurations

## Dépannage

### Problèmes courants

1. Échec de sauvegarde :
```bash
# Vérifier les logs
make logs service=backup

# Vérifier l'espace disque
df -h
```
2. Échec de restauration :
```bash
# Vérifier l'intégrité de la sauvegarde
make backup-verify file=<backup-name>

# Restauration en mode debug
make restore-debug file=<backup-name>
``` 
3.Problèmes d'espace disque :
```bash
# Nettoyer les anciennes sauvegardes
make backup-clean

# Optimiser les sauvegardes
make backup-optimize
```