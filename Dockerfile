FROM php:8.2-fpm-bullseye

ARG NEXMAIL_VERSION=1.0.1
ENV APP_ENV=production

# Системные зависимости для PECL и PHP
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    git \
    libicu-dev \
    libzip-dev \
    mariadb-client \
    libonig-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# PHP расширения
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    intl \
    mbstring \
    zip \
    opcache

# PECL Redis (работает на Debian)
RUN pecl install redis-7.6.0 \
    && docker-php-ext-enable redis

# Скачиваем release ZIP NexMail вместо git clone
WORKDIR /var/www/html
RUN curl -L https://codeberg.org/nexmail/NexMail/releases/download/${NEXMAIL_VERSION}/${NEXMAIL_VERSION}.zip \
    -o nexmail.zip \
    && unzip nexmail.zip \
    && rm nexmail.zip

# Entrypoint
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER www-data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
