# Dockerfile
FROM php:8.2-fpm

# Installation des extensions nécessaires à Symfony + Doctrine
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    zip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-install pdo pdo_mysql

# Copier Composer depuis une image officielle
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer