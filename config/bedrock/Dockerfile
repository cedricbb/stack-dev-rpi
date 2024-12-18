ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install zip pdo pdo_mysql

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configuration de PHP
COPY php.ini /usr/local/etc/php/conf.d/bedrock.ini

# Configuration du répertoire de travail
WORKDIR /var/www/html

# Définission des permissions
RUN chown -R www-data:www-data /var/www/html