SHELL := /bin/bash
DATE := $(shell date +%Y-%m-%d-%H-%M-%S)
DOCKER_COMPOSE = docker-compose

# Dossiers
CONFIG_DIR := config
BACKUP_DIR := backup
PROJECT_DIR := projects
LOGS_DIR := logs