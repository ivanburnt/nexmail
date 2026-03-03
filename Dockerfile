RUN pecl install redis && docker-php-ext-enable redis

# --------------------------
# Runtime image
# --------------------------
FROM php:8.2-fpm-alpine

ARG NEXMAIL_VERSION=1.0.1

ENV APP_ENV=production

# System deps
RUN apk add --no-cache \
    bash \
    curl \
    unzip \
    icu-dev \
    oniguruma-dev \
    libzip-dev \
    mariadb-client \
    redis \
    libzip-dev \
    mariadb-client \
    redis \
    autoconf \
    gcc \
    g++ \
    make \
    linux-headers

# PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    intl \
    mbstring \
    zip \
    opcache

RUN pecl install redis && docker-php-ext-enable redis

WORKDIR /var/www/html

# Download release
RUN curl -L \
    https://codeberg.org/nexmail/NexMail/releases/download/${NEXMAIL_VERSION}/${NEXMAIL_VERSION}.zip \
    -o nexmail.zip \
    && unzip nexmail.zip \
    && rm nexmail.zip

# Permissions
RUN chown -R www-data:www-data /var/www/html

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER www-data

ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
