FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    unzip git curl libpng-dev libonig-dev libxml2-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY app.zip /var/www/html/app.zip
COPY browser.zip /var/www/html/browser.zip

RUN unzip app.zip && unzip browser.zip && rm app.zip browser.zip

# 🔥 AUTO-DETECT composer.json LOCATION
RUN set -eux; \
    COMPOSER_DIR=$(find /var/www/html -name composer.json -type f | head -n 1 | xargs dirname); \
    echo "Composer found in: $COMPOSER_DIR"; \
    cd "$COMPOSER_DIR"; \
    composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data /var/www/html || true
RUN chmod -R 775 /var/www/html || true

RUN a2enmod rewrite

EXPOSE 80
