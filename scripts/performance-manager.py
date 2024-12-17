#1/usr/bin/env python3
import docker
import psutil
import time
import json
import requests
from datetime import datetime

class PerformanceManager:
    def __init__(self):
        self.docker_client = docker.from_env()
        self.alerts = []
        self.threshold = {
            'cpu_percent': 80,
            'memory_percent': 85,
            'disk_percent': 90,
        }

    def check_system_ressources(self):
        """Vérifie les ressources systèmes"""
        cpu_percent = psutil.cpu_percent(interval=1)
        memory_percent = psutil.virtual_memory().percent
        disk_percent = psutil.disk_usage('/').percent

        return {
            'cpu': cpu_percent,
            'memory': memory_percent,
            'disk': disk_percent,
            'timestamp': datetime.now().isoformat()
        }
    
    def check_container_ressources(self):
        """Vérifie les ressources des conteneurs"""
        container_stats = []

        for container in self.docker_client.containers.list():
            stats = container.stats(stream=False)
            container_stats.append({
                'name': container.name,
                'cpu': self._calculate_cpu_percent(stats),
                'memory': self._calculatte_memory_percent(stats),
                'timestamp': datetime.now().isoformat()
            })


        return container_stats
    
    def optimize_containers(self):
        """Optimise les conteneurs"""
        for container in self.docker_client.containers.list():
            stats = container.stats(stream=False)
            cpu_percent = self._calculate_cpu_percent(stats)
            memory_percent = self._calculatte_memory_percent(stats)

            if cpu_percent > self.threshold['cpu_percent'] or \
                memory_percent > self.threshold['memory_percent']:
                self._handle_high_usage(container)

    def _handle_high_usage(self, container):
        """Gère les conteneurs a haute utilisation"""
        container_info = container.attrs

        # Vérifier si le conteneur peut être redémarré
        restart_policy = container_info['HostConfig']['RestartPolicy']['Name']
        if restart_policy != 'no':
            self.alerts.append({
                'container': container.name,
                'action': 'restart',
                'reason': 'High CPU or memory usage',
                'timestamp': datetime.now().isoformat()
            })
            container.restart()

    def _calculate_cpu_percent(self, stats):
        """Calcule le pourcentage CPU"""
        cpu_count = len(stats['cpu_stats']['cpu_usage']['percpu_usage'])
        cpu_percent = 0.0
        cpu_delta = float(stats['cpu_stats']['cpu_usage']['total_usage']) - float(stats['precpu_stats']['cpu_usage']['total_usage'])
        system_delta = float(stats['cpu_stats']['system_cpu_usage']) - float(stats['precpu_stats']['system_cpu_usage'])

        if system_delta > 0.0:
            cpu_percent = (cpu_delta / system_delta) * 100.0 * cpu_count
        return cpu_percent
    
    def _calculatte_memory_percent(self, stats):
        """Calcule le pourcentage de mémoire"""
        usage = stats['memory_stats'].get('usage', 0)
        limit = stats['memory_stats'].get('limit', 0)
        return (usage / limit) * 100.0
    
    def generate_report(self):
        """Génère un rapport de performance"""

        report = {
            'system': self.check_system_ressources(),
            'containers': self.check_container_ressources(),
            'alerts': self.alerts
        }

        return report
    
    def save_report(self, report):
        """Sauvegarde le rapport de performance"""
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        with open(f'reports/performance-{timestamp}.json', 'w') as f:
            json.dump(report, f, indent=2)

if __name__ == '__main__':
    manager = PerformanceManager()
    
    while True:
        report = manager.generate_report()
        manager.save_report(report)
        manager.optimize_containers()
        time.sleep(300)