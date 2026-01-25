ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip libzip-dev \
    libpq-dev nodejs npm # Required for PostgreSQL if needed

# Install PHP extensions for Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# --- ADD BUN INSTALLATION HERE ---
RUN curl -fsSL https://bun.sh/install | bash \
    && mv /root/.bun/bin/bun /usr/local/bin/bun \
    && ln -sf /usr/local/bin/bun /usr/local/bin/bunx

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create a system user to match Arch Linux UID (usually 1000)
ARG USER_ID=1000
RUN useradd -u ${USER_ID} -m -s /bin/bash laravel

# Set PATH for all users to include bun
ENV PATH="/usr/local/bin:$PATH"

# Copy custom PHP configuration
COPY docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini

# Create bunx symlink before switching users
RUN ln -sf /usr/local/bin/bun /usr/local/bin/bunx

USER laravel

# Install Laravel Installer
RUN composer global require laravel/installer

# Add PHP Composer global bin to PATH
ENV PATH="/home/laravel/.composer/vendor/bin:${PATH}"

WORKDIR /var/www
