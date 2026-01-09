FROM php:8.2-apache

# System dependencies
RUN apt-get update && apt-get install -y \
    unzip git curl libpng-dev libonig-dev libxml2-dev zip \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy ZIP files
COPY app.zip /var/www/html/app.zip
COPY browser.zip /var/www/html/browser.zip

# Unzip both ZIP files and remove them
RUN unzip app.zip && unzip browser.zip && rm app.zip browser.zip

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Enable Apache rewrite
RUN a2enmod rewrite

EXPOSE 80
