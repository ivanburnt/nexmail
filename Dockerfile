FROM php:8.2-fpm-alpine

ARG NEXMAIL_VERSION=1.0.1
ENV APP_ENV=production

# Системные зависимости для PECL
RUN apk add --no-cache \
    bash \
    curl \
    unzip \
    icu-dev \
    oniguruma-dev \
    libzip-dev \
    mariadb-client \
    autoconf \
    gcc \
    g++ \
    make \
    linux-headers \
    php8-dev

# PHP расширения
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    intl \
    mbstring \
    zip \
    opcache

# PECL Redis
RUN pecl install redis-7.6.0 \
    && docker-php-ext-enable redis

# Release ZIP NexMail
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
