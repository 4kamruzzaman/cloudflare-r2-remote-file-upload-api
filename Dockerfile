# -------------------------------------------
# BizSafer Standard: Base Image (LTS)
# -------------------------------------------
FROM php:8.2-apache

# -------------------------------------------
# 1. Install System Dependencies
# Required for zip handling and mysql connectivity
# -------------------------------------------
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    libonig-dev \
    && docker-php-ext-install pdo_mysql zip mbstring

# -------------------------------------------
# 2. Apache Configuration
# Enable mod_rewrite for your .htaccess files
# -------------------------------------------
RUN a2enmod rewrite

# -------------------------------------------
# 3. Install Composer
# Get the official dependency manager
# -------------------------------------------
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# -------------------------------------------
# 4. Set Working Directory
# -------------------------------------------
WORKDIR /var/www/html

# -------------------------------------------
# 5. Dependency Installation (Cache Layer)
# We copy composer files FIRST to speed up future builds
# -------------------------------------------
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# -------------------------------------------
# 6. Copy Application Code
# -------------------------------------------
COPY . .

# -------------------------------------------
# 7. Permissions & Cleanup
# Ensure the web server owns the files
# -------------------------------------------
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# -------------------------------------------
# 8. Entrypoint
# -------------------------------------------
CMD ["apache2-foreground"]