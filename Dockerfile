FROM php:8.2-fpm

ARG NEXMAIL_VERSION=1.0.1
WORKDIR /var/www/html

# PHP расширения
RUN docker-php-ext-install pdo pdo_mysql mbstring zip opcache intl

# Скачиваем NexMail release
RUN curl -L https://codeberg.org/nexmail/NexMail/releases/download/${NEXMAIL_VERSION}/${NEXMAIL_VERSION}.zip \
    -o nexmail.zip && unzip nexmail.zip && rm nexmail.zip

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
