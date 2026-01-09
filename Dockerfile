FROM php:8.2-apache

# System dependencies
RUN apt-get update && apt-get install -y \
    unzip git curl libpng-dev libonig-dev libxml2-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy ZIP files
COPY app.zip /var/www/html/app.zip
COPY browser.zip /var/www/html/browser.zip

# Unzip ZIP files
RUN unzip app.zip && unzip browser.zip && rm app.zip browser.zip

# 👉 IMPORTANT: find composer.json and run composer there
RUN set -eux; \
    if [ -f composer.json ]; then \
        composer install --no-dev --optimize-autoloader; \
    else \
        cd app && composer install --no-dev --optimize-autoloader; \
    fi

# Permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache || true

RUN a2enmod rewrite

EXPOSE 80
