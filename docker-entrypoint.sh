#!/bin/sh
set -e

echo "Waiting for database..."
until mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" >/dev/null 2>&1; do
  sleep 2
done

if [ ! -f .env ]; then
  cp .env_sample .env
  sed -i "s/DB_HOST=.*/DB_HOST=$DB_HOST/" .env
  sed -i "s/DB_NAME=.*/DB_NAME=$DB_NAME/" .env
  sed -i "s/DB_USER=.*/DB_USER=$DB_USER/" .env
  sed -i "s/DB_PASS=.*/DB_PASS=$DB_PASS/" .env
  sed -i "s/DOMAIN=.*/DOMAIN=$DOMAIN/" .env
fi

if [ ! -f storage/encryption_key.bin ]; then
  php -r "file_put_contents('storage/encryption_key.bin', sodium_crypto_secretbox_keygen());"
fi

if ! mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES;" | grep users >/dev/null 2>&1; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < database/schema.sql
fi

exec "$@"