# Guide Monitoring et Surveillance

## Architecture de monitoring

### Composants

- Prometheus : Collecte des métriques
- Grafana : Visualisation
- Node Exporter : Métriques système
- cAdvisor : Métriques Docker
- AlertManager : Gestion des alertes

## Prometheus

### Configuration

```yaml
# config/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
  - job_name: 'node'
  - job_name: 'docker'
```

### Règles d'alerte
```yaml
# config/prometheus/rules/node.rules
groups:
  - name: node
    rules:
      - alert: HighCPULoad
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
```

## Grafana

### Dashboards préconfigurés

1. System Overview
- CPU Usage
- Memory Usage
- Disk Space
- Network Traffic
2. Docker Containers
- Container Status
- Resource Usage
- Network Stats
3. Appllication Metrics
- Response Times
- Error Rates
-Request Counts

### Configuration des alertes :
```ini
# config/grafana/alerting.ini
[alerting]
enabled = true
execute_alerts = true
```
### Métriques collectées :

#### Système

- CPU Usage
- Memory Usage
- Disk Space
- Network IO
- System Load

#### Docker

- Container Status
- Resource Usage
- Network Stats
- Volume Usage

#### Applications
- Response Times
- Error Rates
- Request Counts
- Database Queries

## Alertes

### Configuration :

#### 1.Discord
```yaml
receivers:
  - name: 'discord'
    discord_configs:
      - webhook_url: '${DISCORD_WEBHOOK_URL}'
```
#### 2.Email
```yaml
receivers:
  - name: 'email'
    email_configs:
      - to: 'admin@example.com'
```

### Règles d'alerte :

#### 1.Système
```yaml
- alert: HighMemoryUsage
  expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
```
#### 2.Services
```yaml
- alert: ServiceDown
  expr: up == 0
```

### Visualisation

#### URLs d'accès
- Prometheus : https://prometheus.localhost
- Grafana : https://grafana.localhost
- AlertManager : https://alertmanager.localhost

### Authentification

```bash
# Grafana admin
Username: admin
Password: ${GRAFANA_PASSWORD}
```
## Maintenance :

### Rétention des données

```yaml
# Prometheus
storage:
  tsdb:
    retention.time: 15d
``` 

### Backup des dashboards
```bash
make grafana-backup
```

### Nettoyage
```bash
make clean-metrics
```
